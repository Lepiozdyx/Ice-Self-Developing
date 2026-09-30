import SwiftData
import SwiftUI

enum CourseSection: String, CaseIterable, Identifiable {
    case route = "Route"
    case skills = "Skills"
    case warmSteps = "Warm Steps"

    var id: String { rawValue }
}

struct CourseView: View {
    @Environment(AppStore.self) private var store
    @State private var section: CourseSection = .route
    @State private var isEditingGoal = false
    @State private var isAddingSkill = false
    @State private var isAddingStep = false
    @State private var expandedSkillID: PersistentIdentifier?

    var body: some View {
        ScreenContainer {
            VStack(alignment: .leading, spacing: 14) {
                header
                segment
                Group {
                    switch section {
                    case .route:
                        route
                    case .skills:
                        skills
                    case .warmSteps:
                        warmSteps
                    }
                }
            }
            .padding(.top, 8)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                SectionKicker(title: "MY COURSE")
                HStack(spacing: 8) {
                    Image(systemName: "light.beacon.max.fill")
                        .foregroundStyle(Theme.warmEnd)
                    Text("Lighthouse")
                        .foregroundStyle(.white)
                }
                .font(.largeTitle.weight(.bold))
            }
            Spacer()
            if section == .skills || section == .warmSteps {
                PlusButton {
                    if section == .skills {
                        isAddingSkill.toggle()
                    } else {
                        isAddingStep.toggle()
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var segment: some View {
        HStack(spacing: 6) {
            ForEach(CourseSection.allCases) { item in
                Button {
                    section = item
                } label: {
                    Text(item.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if section == item {
                                Capsule().fill(Theme.accentDeep)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Theme.card, in: Capsule())
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var route: some View {
        ScrollView {
            VStack(spacing: 16) {
                if isEditingGoal || store.goal == nil && isEditingGoal {
                    GoalEditor(onCancel: { isEditingGoal = false }, onSave: { isEditingGoal = false })
                } else if let goal = store.goal {
                    goalCard(goal)
                } else {
                    emptyGoal
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    private var emptyGoal: some View {
        SurfaceCard {
            VStack(spacing: 12) {
                Image(systemName: "light.beacon.max.fill")
                    .font(.title2)
                    .foregroundStyle(Theme.warmEnd)
                    .frame(width: 64, height: 64)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.cardRaised))
                Text("Add your goal")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                Text("Define where you want to go.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
                Button {
                    isEditingGoal = true
                } label: {
                    Text("Add Goal")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Theme.accent))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
        }
    }

    private func goalCard(_ goal: LighthouseGoal) -> some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(goal.name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button("Edit") { isEditingGoal = true }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                }
                if !goal.why.isEmpty {
                    Text(goal.why)
                        .font(.body)
                        .foregroundStyle(Theme.secondaryText)
                }
                HStack(alignment: .top, spacing: 12) {
                    pointColumn(title: "Point A — Where I am", value: goal.pointA)
                    Image(systemName: "arrow.right")
                        .foregroundStyle(Theme.secondaryText)
                        .padding(.top, 22)
                    pointColumn(title: "Point B — Where I'm going", value: goal.pointB)
                }
                if !store.orderedCheckpoints.isEmpty {
                    Text("Checkpoints")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.secondaryText)
                    ForEach(Array(store.orderedCheckpoints.enumerated()), id: \.element.persistentModelID) { index, checkpoint in
                        HStack(spacing: 10) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .background(Circle().fill(Theme.accent))
                            Text(checkpoint.title)
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
    }

    private func pointColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(Theme.secondaryText)
            Text(value.isEmpty ? "—" : value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var skills: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if isAddingSkill {
                    NewSkillForm { isAddingSkill = false }
                }
                Text("Tap a skill to edit levels or rename it.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
                ForEach(store.sortedSkills) { skill in
                    SkillSummaryCard(skill: skill) {
                        expandedSkillID = expandedSkillID == skill.persistentModelID ? nil : skill.persistentModelID
                    }
                    if expandedSkillID == skill.persistentModelID {
                        SkillEditor(skill: skill) {
                            store.deleteSkill(skill)
                            expandedSkillID = nil
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    private var warmSteps: some View {
        List {
            if isAddingStep {
                NewWarmStepForm { isAddingStep = false }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 8, trailing: 20))
            }
            Section {
                ForEach(store.sortedWarmSteps) { step in
                    WarmStepRow(step: step)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.deleteWarmStep(step)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            } header: {
                Text("FROM SKILLS")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.secondaryText)
            }
            SurfaceCard {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(Theme.warmEnd)
                    Text("Completing warm steps doesn't automatically raise your skill level — reassess when you feel a genuine shift.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.warmEnd)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 24, trailing: 20))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

private struct GoalEditor: View {
    @Environment(AppStore.self) private var store
    var onCancel: () -> Void
    var onSave: () -> Void

    @State private var name = ""
    @State private var why = ""
    @State private var pointA = ""
    @State private var pointB = ""
    @State private var checkpoints: [String] = []
    @State private var draftCheckpoint = ""

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    SectionKicker(title: "CREATE GOAL")
                    Spacer()
                    Button("Cancel", action: onCancel)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.secondaryText)
                }
                Text("Goal name")
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                FieldBox(text: $name, placeholder: "Become a Product Manager")
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Point A — Where I am")
                            .font(.caption2)
                            .foregroundStyle(Theme.secondaryText)
                        FieldBox(text: $pointA, placeholder: "Developer")
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Point B — Where I'm going")
                            .font(.caption2)
                            .foregroundStyle(Theme.warmEnd)
                        FieldBox(text: $pointB, placeholder: "Product Manager")
                    }
                }
                Text("Checkpoints")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                ForEach(checkpoints.indices, id: \.self) { index in
                    HStack(spacing: 8) {
                        Text("\(index + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Theme.accent))
                        TextField("Checkpoint", text: $checkpoints[index])
                            .foregroundStyle(.white)
                        Button {
                            checkpoints.remove(at: index)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(Theme.warmStart)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(10)
                    .background(Theme.field, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                HStack(spacing: 8) {
                    TextField("Add a checkpoint...", text: $draftCheckpoint)
                        .foregroundStyle(.white)
                    Button {
                        let clean = draftCheckpoint.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !clean.isEmpty else { return }
                        checkpoints.append(clean)
                        draftCheckpoint = ""
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Theme.accent)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Theme.cardRaised))
                    }
                    .buttonStyle(.plain)
                }
                .padding(10)
                .background(Theme.field, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                PrimaryButton(
                    title: "Save Goal",
                    isEnabled: !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ) {
                    var titles = checkpoints
                    let pending = draftCheckpoint.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !pending.isEmpty {
                        titles.append(pending)
                    }
                    store.saveGoal(name: name, why: why, pointA: pointA, pointB: pointB, checkpoints: titles)
                    onSave()
                }
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard let goal = store.goal else { return }
        name = goal.name
        why = goal.why
        pointA = goal.pointA
        pointB = goal.pointB
        checkpoints = store.orderedCheckpoints.map(\.title)
    }
}

private struct SkillSummaryCard: View {
    var skill: Skill
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            SurfaceCard {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(skill.name)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Spacer()
                        Text(skill.priority.rawValue)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Theme.warmEnd)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Theme.warmEnd.opacity(0.16)))
                    }
                    HStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current")
                                .font(.caption2)
                                .foregroundStyle(Theme.secondaryText)
                            LevelDots(value: skill.currentLevel)
                        }
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Target")
                                .font(.caption2)
                                .foregroundStyle(Theme.secondaryText)
                            LevelDots(value: skill.targetLevel)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Gap")
                                .font(.caption2)
                                .foregroundStyle(Theme.secondaryText)
                            Text(skill.gap == 0 ? "0" : "-\(skill.gap)")
                                .font(.headline)
                                .foregroundStyle(Theme.warmEnd)
                        }
                    }
                    MeterBar(fraction: Double(skill.currentLevel) / 5)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct SkillEditor: View {
    @Environment(AppStore.self) private var store
    var skill: Skill
    var onDelete: () -> Void
    @State private var draftName = ""

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Skill name")
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                FieldBox(text: $draftName, placeholder: "Skill name")
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current level")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                        LevelStepper(value: skill.currentLevel) { value in
                            store.updateSkill(skill, name: draftName, current: value, target: skill.targetLevel)
                        }
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.right")
                            .foregroundStyle(Theme.secondaryText)
                        Text("gap \(skill.gap)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Theme.warmEnd)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target level")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                        LevelStepper(value: skill.targetLevel) { value in
                            store.updateSkill(skill, name: draftName, current: skill.currentLevel, target: value)
                        }
                    }
                }
                Text("Suggested warm steps")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                ForEach(WarmStepLibrary.templates(for: skill.name).prefix(3), id: \.self) { template in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 7))
                            .foregroundStyle(Theme.warmEnd)
                            .padding(.top, 6)
                        Text(template.title)
                            .font(.subheadline)
                            .foregroundStyle(Theme.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                Button(role: .destructive, action: onDelete) {
                    Label("Remove skill", systemImage: "trash")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.warmStart)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Capsule().stroke(Theme.warmStart.opacity(0.7), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear { draftName = skill.name }
        .onChange(of: draftName) { _, newValue in
            store.updateSkill(skill, name: newValue, current: skill.currentLevel, target: skill.targetLevel)
        }
    }
}

private struct NewSkillForm: View {
    @Environment(AppStore.self) private var store
    var onCancel: () -> Void
    @State private var name = ""
    @State private var current = 1
    @State private var target = 3

    private var gap: Int { max(0, target - current) }

    var body: some View {
        SurfaceCard(stroke: Theme.accent.opacity(0.45)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("New Skill")
                        .font(.headline)
                        .foregroundStyle(Theme.accent)
                    Spacer()
                    Button("Cancel", action: onCancel)
                        .foregroundStyle(Theme.secondaryText)
                }
                Text("Skill name")
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                FieldBox(text: $name, placeholder: "Software")
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                        LevelStepper(value: current) { current = $0 }
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                        LevelStepper(value: target) { target = $0 }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("Gap")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                        Text(gap == 0 ? "0" : "-\(gap)")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Theme.warmEnd)
                    }
                }
                MeterBar(fraction: Double(current) / 5)
                PrimaryButton(
                    title: "Add Skill",
                    isEnabled: !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ) {
                    store.addSkill(name: name, current: current, target: target)
                    onCancel()
                }
            }
        }
    }
}

private struct WarmStepRow: View {
    @Environment(AppStore.self) private var store
    var step: WarmStep

    var body: some View {
        Button {
            store.setWarmStep(step, done: !step.isDone)
        } label: {
            SurfaceCard {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: step.isDone ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(step.isDone ? Theme.complete : Theme.secondaryText)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .strikethrough(step.isDone)
                            .multilineTextAlignment(.leading)
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Theme.accent)
                                .frame(width: 6, height: 6)
                            Text("\(step.skillName) · \(step.priority.rawValue) priority")
                                .font(.caption)
                                .foregroundStyle(Theme.secondaryText)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct NewWarmStepForm: View {
    @Environment(AppStore.self) private var store
    var onCancel: () -> Void
    @State private var title = ""
    @State private var skillName = ""
    @State private var priority: StepPriority = .medium

    var body: some View {
        SurfaceCard(stroke: Theme.warmEnd.opacity(0.7)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("New Micro-step")
                        .font(.headline)
                        .foregroundStyle(Theme.warmEnd)
                    Spacer()
                    Button("Cancel", action: onCancel)
                        .foregroundStyle(Theme.secondaryText)
                }
                Text("Micro-step")
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                FieldBox(text: $title, placeholder: "One small action")
                Text("Related skill")
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                if store.skillsByCreation.isEmpty {
                    Text("Add a skill first.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 8)], alignment: .leading, spacing: 8) {
                        ForEach(store.skillsByCreation) { skill in
                            FilterChip(title: skill.name, isSelected: skillName == skill.name) {
                                skillName = skill.name
                            }
                        }
                    }
                }
                Text("Priority")
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                HStack(spacing: 8) {
                    ForEach(StepPriority.allCases) { item in
                        FilterChip(title: item.rawValue, isSelected: priority == item) {
                            priority = item
                        }
                    }
                }
                PrimaryButton(
                    title: "Add Micro-step",
                    isEnabled: !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !skillName.isEmpty
                ) {
                    store.addWarmStep(title: title, skillName: skillName, priority: priority)
                    onCancel()
                }
            }
        }
        .onAppear {
            if skillName.isEmpty {
                skillName = store.skillsByCreation.first?.name ?? ""
            }
        }
    }
}
