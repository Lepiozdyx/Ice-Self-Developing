import Foundation
import SwiftData
import SwiftUI

struct CourseOfDay {
    var title: String
    var subtitle: String?
}

struct SphereShare: Identifiable {
    var sphere: LifeSphere
    var percent: Int
    var id: String { sphere.rawValue }
}

struct WeekBar: Identifiable {
    var date: Date
    var label: String
    var percent: Int
    var id: Date { date }
}

struct OnboardingSkill: Identifiable {
    let id = UUID()
    var name: String
    var current: Int
    var target: Int

    var gap: Int { max(0, target - current) }

    static let defaults: [OnboardingSkill] = [
        OnboardingSkill(name: "Data Analytics", current: 2, target: 4),
        OnboardingSkill(name: "Product Thinking", current: 3, target: 5),
        OnboardingSkill(name: "SQL / Python", current: 1, target: 3)
    ]
}

@MainActor
@Observable
final class AppStore {
    private let context: ModelContext

    private(set) var profile: UserProfile?
    private(set) var goal: LighthouseGoal?
    private(set) var skills: [Skill] = []
    private(set) var warmSteps: [WarmStep] = []
    private(set) var entries: [JournalEntry] = []
    private(set) var morningRituals: [MorningRitual] = []
    private(set) var eveningRituals: [EveningRitual] = []

    var selectedTab: AppTab = .helm
    var helmPath = NavigationPath()
    var journalPath = NavigationPath()

    init(context: ModelContext) {
        self.context = context
        reload()
    }

    func prepareForLaunch() {
        reload()
        applyDailyDecayIfNeeded()
        rollWeekIfNeeded()
        save()
        reload()
    }

    var displayName: String {
        let name = profile?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty ? "User" : name
    }

    var willTemperature: Int {
        profile?.willTemperature ?? 0
    }

    var iceMeltedPercent: Int {
        Int((profile?.iceMelted ?? 0).rounded())
    }

    var iceThisWeek: Int {
        let delta = (profile?.iceMelted ?? 0) - (profile?.iceAtWeekStart ?? 0)
        return Int(delta.rounded())
    }

    var helmDays: Int {
        profile?.helmStreak ?? 0
    }

    var remindersEnabled: Bool {
        profile?.remindersEnabled ?? false
    }

    var units: MeasurementUnits {
        profile?.units ?? .metric
    }

    var awarenessPercent: Int {
        let total = entries.count
        guard total > 0 else { return 0 }
        let course = entries.filter { $0.vector == .course }.count
        return Int((Double(course) / Double(total) * 100).rounded())
    }

    var authorship: AuthorshipLevel {
        let ice = profile?.iceMelted ?? 0
        let days = profile?.helmStreak ?? 0
        let awareness = Double(awarenessPercent)
        let hasGoal = goal != nil
        let hasActivity = !entries.isEmpty || !morningRituals.isEmpty || !eveningRituals.isEmpty
        if ice >= 80, awareness >= 75, days >= 60 { return .lighthouse }
        if ice >= 45, awareness >= 60, days >= 21, hasGoal { return .captain }
        if ice >= 15, awareness >= 50, days >= 10 { return .navigator }
        if ice >= 5 || days >= 3 { return .rower }
        if hasActivity { return .awakening }
        return .iceSheet
    }

    var sortedSkills: [Skill] {
        skills.sorted { lhs, rhs in
            if lhs.gap != rhs.gap { return lhs.gap > rhs.gap }
            return lhs.createdAt < rhs.createdAt
        }
    }

    var skillsByCreation: [Skill] {
        skills.sorted { $0.createdAt < $1.createdAt }
    }

    var sortedWarmSteps: [WarmStep] {
        warmSteps.sorted { lhs, rhs in
            if lhs.isDone != rhs.isDone { return !lhs.isDone && rhs.isDone }
            return lhs.createdAt < rhs.createdAt
        }
    }

    var sortedEntries: [JournalEntry] {
        entries.sorted { $0.createdAt > $1.createdAt }
    }

    var orderedCheckpoints: [Checkpoint] {
        goal?.orderedCheckpoints ?? []
    }

    func morningRitual(on date: Date = .now) -> MorningRitual? {
        morningRituals.first { DateHelpers.isSameDay($0.dayStart, date) }
    }

    func eveningRitual(on date: Date = .now) -> EveningRitual? {
        eveningRituals.first { DateHelpers.isSameDay($0.dayStart, date) }
    }

    var courseOfDay: CourseOfDay {
        let subtitle = goal.map { "Step toward: \($0.name)" }
        if let morning = morningRitual() {
            let title = morning.warmStep.isEmpty ? morning.intention : morning.warmStep
            return CourseOfDay(title: title, subtitle: subtitle)
        }
        if let step = sortedWarmSteps.first(where: { !$0.isDone }) {
            return CourseOfDay(title: step.title, subtitle: subtitle)
        }
        return CourseOfDay(title: "Set one intention for today", subtitle: subtitle)
    }

    func sphereShares() -> [SphereShare] {
        let total = entries.count
        guard total > 0 else { return [] }
        return LifeSphere.allCases.compactMap { sphere in
            let count = entries.filter { $0.sphere == sphere }.count
            guard count > 0 else { return nil }
            let percent = Int((Double(count) / Double(total) * 100).rounded())
            return SphereShare(sphere: sphere, percent: percent)
        }
        .sorted { $0.percent > $1.percent }
    }

    func weekBars() -> [WeekBar] {
        let start = DateHelpers.startOfWeek(for: .now)
        let labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return labels.indices.map { index in
            let date = DateHelpers.addingDays(index, to: start)
            let dayEntries = entries.filter { DateHelpers.isSameDay($0.createdAt, date) }
            let percent: Int
            if dayEntries.isEmpty {
                percent = 0
            } else {
                let course = dayEntries.filter { $0.vector == .course }.count
                percent = Int((Double(course) / Double(dayEntries.count) * 100).rounded())
            }
            return WeekBar(date: date, label: labels[index], percent: percent)
        }
    }

    func openRitual(_ kind: RitualKind) {
        selectedTab = .helm
        helmPath.append(HelmRoute.rituals(kind))
    }

    func openCourse() {
        selectedTab = .course
    }

    func openStatistics() {
        selectedTab = .statistics
    }

    func openNewMoment() {
        selectedTab = .journal
        journalPath = NavigationPath()
        journalPath.append(JournalRoute.newMoment)
    }

    func completeOnboarding(lighthouse: String, why: String, skills draftSkills: [OnboardingSkill]) {
        let name = lighthouse.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let profile = UserProfile(
            name: "User",
            onboardingCompleted: true,
            willTemperature: 40,
            weekStart: DateHelpers.startOfWeek(for: .now),
            lastDecayDay: .now
        )
        context.insert(profile)

        let goal = LighthouseGoal(
            name: name,
            why: why.trimmingCharacters(in: .whitespacesAndNewlines),
            pointA: "",
            pointB: name
        )
        context.insert(goal)

        let existingTitles = Set(warmSteps.map(\.title))
        var stamp = Date()
        for draft in draftSkills {
            let skillName = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !skillName.isEmpty else { continue }
            stamp = stamp.addingTimeInterval(1)
            context.insert(
                Skill(
                    name: skillName,
                    currentLevel: draft.current,
                    targetLevel: draft.target,
                    createdAt: stamp
                )
            )
            for template in WarmStepLibrary.templates(for: skillName).prefix(3) where !existingTitles.contains(template.title) {
                stamp = stamp.addingTimeInterval(1)
                context.insert(
                    WarmStep(
                        title: template.title,
                        skillName: skillName,
                        priority: template.priority,
                        createdAt: stamp
                    )
                )
            }
        }
        save()
        reload()
    }

    func saveMorning(intention: String, warmStep: String, anchor: String) {
        guard morningRitual() == nil else { return }
        context.insert(
            MorningRitual(
                dayStart: DateHelpers.startOfDay(.now),
                intention: intention.trimmingCharacters(in: .whitespacesAndNewlines),
                warmStep: warmStep.trimmingCharacters(in: .whitespacesAndNewlines),
                anchor: anchor.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        )
        adjustTemperature(2)
        markHelmDay()
        save()
        reload()
    }

    func saveEvening(score: Int, drift: String, proud: String, lesson: String) {
        guard eveningRitual() == nil else { return }
        let clamped = min(10, max(0, score))
        context.insert(
            EveningRitual(
                dayStart: DateHelpers.startOfDay(.now),
                authorScore: clamped,
                driftNote: drift.trimmingCharacters(in: .whitespacesAndNewlines),
                proudNote: proud.trimmingCharacters(in: .whitespacesAndNewlines),
                lesson: lesson.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        )
        adjustTemperature(AuthorScore.temperatureDelta(for: clamped))
        adjustIce(AuthorScore.iceDelta(for: clamped))
        markHelmDay()
        save()
        reload()
    }

    func addMoment(text: String, insight: String, vector: MomentVector, sphere: LifeSphere) {
        context.insert(
            JournalEntry(
                text: text.trimmingCharacters(in: .whitespacesAndNewlines),
                insight: insight.trimmingCharacters(in: .whitespacesAndNewlines),
                vector: vector,
                sphere: sphere
            )
        )
        if vector == .course {
            adjustTemperature(2)
            adjustIce(1)
        }
        markHelmDay()
        save()
        reload()
    }

    func saveGoal(name: String, why: String, pointA: String, pointB: String, checkpoints titles: [String]) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { return }
        let cleanTitles = titles
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let goal: LighthouseGoal
        if let existing = self.goal {
            goal = existing
            goal.name = cleanName
            goal.why = why.trimmingCharacters(in: .whitespacesAndNewlines)
            goal.pointA = pointA.trimmingCharacters(in: .whitespacesAndNewlines)
            goal.pointB = pointB.trimmingCharacters(in: .whitespacesAndNewlines)
            for checkpoint in Array(existing.checkpoints) {
                context.delete(checkpoint)
            }
        } else {
            goal = LighthouseGoal(
                name: cleanName,
                why: why.trimmingCharacters(in: .whitespacesAndNewlines),
                pointA: pointA.trimmingCharacters(in: .whitespacesAndNewlines),
                pointB: pointB.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            context.insert(goal)
        }

        for (index, title) in cleanTitles.enumerated() {
            context.insert(Checkpoint(title: title, sortOrder: index, goal: goal))
        }
        save()
        reload()
    }

    func addSkill(name: String, current: Int, target: Int) {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        context.insert(Skill(name: clean, currentLevel: current, targetLevel: target))
        insertMissingTemplates(for: clean, limit: 3)
        save()
        reload()
    }

    func updateSkill(_ skill: Skill, name: String, current: Int, target: Int) {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let previous = skill.name
        if !clean.isEmpty, clean != previous {
            for step in warmSteps where step.skillName == previous {
                step.skillName = clean
            }
            skill.name = clean
        }
        skill.currentLevel = min(5, max(1, current))
        skill.targetLevel = min(5, max(1, target))
        save()
    }

    func deleteSkill(_ skill: Skill) {
        let name = skill.name
        for step in warmSteps where step.skillName == name {
            if step.isDone {
                adjustTemperature(-1)
                adjustIce(-1)
            }
            context.delete(step)
        }
        context.delete(skill)
        save()
        reload()
    }

    func addWarmStep(title: String, skillName: String, priority: StepPriority) {
        let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        context.insert(WarmStep(title: clean, skillName: skillName, priority: priority))
        save()
        reload()
    }

    func setWarmStep(_ step: WarmStep, done: Bool) {
        guard step.isDone != done else { return }
        step.isDone = done
        adjustTemperature(done ? 1 : -1)
        adjustIce(done ? 1 : -1)
        if done {
            markHelmDay()
        }
        save()
    }

    func deleteWarmStep(_ step: WarmStep) {
        if step.isDone {
            adjustTemperature(-1)
            adjustIce(-1)
        }
        context.delete(step)
        save()
        reload()
    }

    func setName(_ name: String) {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        profile?.name = clean
        save()
    }

    func setUnits(_ units: MeasurementUnits) {
        profile?.units = units
        save()
    }

    func setRemindersEnabled(_ enabled: Bool) async {
        if enabled {
            let granted = await ReminderScheduler.enable()
            profile?.remindersEnabled = granted
        } else {
            ReminderScheduler.disable()
            profile?.remindersEnabled = false
        }
        save()
    }

    private func insertMissingTemplates(for skillName: String, limit: Int) {
        let existing = Set(warmSteps.map(\.title))
        var stamp = Date()
        for template in WarmStepLibrary.templates(for: skillName).prefix(limit) where !existing.contains(template.title) {
            stamp = stamp.addingTimeInterval(1)
            context.insert(
                WarmStep(
                    title: template.title,
                    skillName: skillName,
                    priority: template.priority,
                    createdAt: stamp
                )
            )
        }
    }

    private func adjustTemperature(_ delta: Int) {
        guard let profile else { return }
        profile.willTemperature = min(100, max(0, profile.willTemperature + delta))
    }

    private func adjustIce(_ delta: Double) {
        guard let profile, delta != 0 else { return }
        profile.iceMelted = min(100, max(0, profile.iceMelted + delta))
    }

    private func markHelmDay(on date: Date = .now) {
        guard let profile else { return }
        let today = DateHelpers.startOfDay(date)
        if let last = profile.lastHelmDay, DateHelpers.startOfDay(last) == today {
            return
        }
        if let last = profile.lastHelmDay {
            let missed = DateHelpers.daysBetween(last, today) - 1
            if missed <= 0 {
                profile.helmStreak += 1
            } else {
                profile.helmStreak = max(0, profile.helmStreak - missed) + 1
            }
        } else {
            profile.helmStreak = 1
        }
        profile.lastHelmDay = today
    }

    private func applyDailyDecayIfNeeded() {
        guard let profile else { return }
        let today = DateHelpers.startOfDay(.now)
        guard let lastDecay = profile.lastDecayDay else {
            profile.lastDecayDay = today
            return
        }
        var day = DateHelpers.startOfDay(lastDecay)
        while day < today {
            if eveningRitual(on: day) == nil {
                profile.willTemperature = max(15, profile.willTemperature - 4)
            }
            day = DateHelpers.addingDays(1, to: day)
        }
        profile.lastDecayDay = today
    }

    private func rollWeekIfNeeded() {
        guard let profile else { return }
        let start = DateHelpers.startOfWeek(for: .now)
        guard DateHelpers.startOfDay(profile.weekStart) != start else { return }
        profile.iceAtWeekStart = profile.iceMelted
        profile.weekStart = start
    }

    private func save() {
        try? context.save()
    }

    private func reload() {
        profile = fetch(UserProfile.self).first
        goal = fetch(LighthouseGoal.self).first
        skills = fetch(Skill.self)
        warmSteps = fetch(WarmStep.self)
        entries = fetch(JournalEntry.self)
        morningRituals = fetch(MorningRitual.self)
        eveningRituals = fetch(EveningRitual.self)
    }

    private func fetch<T: PersistentModel>(_ type: T.Type) -> [T] {
        (try? context.fetch(FetchDescriptor<T>())) ?? []
    }
}
