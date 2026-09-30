import Foundation
import SwiftData

@MainActor
enum MockSeed {
    static func applyIfNeeded(context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<UserProfile>())) ?? []
        guard existing.isEmpty else { return }

        let now = Date()
        let profile = UserProfile(
            name: "User",
            remindersEnabled: false,
            units: .metric,
            onboardingCompleted: true,
            willTemperature: 67,
            iceMelted: 18,
            iceAtWeekStart: 15,
            weekStart: DateHelpers.startOfWeek(for: now),
            helmStreak: 34,
            lastHelmDay: DateHelpers.startOfDay(now),
            lastDecayDay: now
        )
        context.insert(profile)

        let goal = LighthouseGoal(
            name: "Become a Product Manager",
            why: "I want to build products that help people and take responsibility for their direction.",
            pointA: "Developer",
            pointB: "Product Manager"
        )
        context.insert(goal)
        context.insert(Checkpoint(title: "Course PM", sortOrder: 0, goal: goal))
        context.insert(Checkpoint(title: "Talk with friends", sortOrder: 1, goal: goal))

        let skills: [(String, Int, Int)] = [
            ("Data Analytics", 2, 4),
            ("Product Thinking", 3, 5),
            ("SQL / Python", 1, 3),
            ("Communication", 2, 4),
            ("Agile / Scrum", 3, 4),
            ("UX Fundamentals", 2, 4),
            ("Software", 1, 3)
        ]
        var stamp = now.addingTimeInterval(-20_000)
        for (name, current, target) in skills {
            stamp = stamp.addingTimeInterval(1)
            context.insert(Skill(name: name, currentLevel: current, targetLevel: target, createdAt: stamp))
        }

        for template in WarmStepLibrary.all {
            stamp = stamp.addingTimeInterval(1)
            context.insert(
                WarmStep(
                    title: template.title,
                    skillName: template.skillName,
                    priority: template.priority,
                    createdAt: stamp
                )
            )
        }

        context.insert(
            MorningRitual(
                dayStart: DateHelpers.startOfDay(now),
                intention: "Study product analytics",
                warmStep: "Spend an hour studying product analytics",
                anchor: "Clarity",
                createdAt: now
            )
        )
        context.insert(
            EveningRitual(
                dayStart: DateHelpers.startOfDay(now),
                authorScore: 7,
                driftNote: "Too much scrolling",
                proudNote: "Finished my case study",
                lesson: "Small steps add up",
                createdAt: now
            )
        )

        for moment in moments {
            context.insert(
                JournalEntry(
                    text: moment.text,
                    insight: moment.insight,
                    vector: moment.vector,
                    sphere: moment.sphere,
                    createdAt: DateHelpers.date(daysAgo: moment.daysAgo, hour: moment.hour, minute: moment.minute)
                )
            )
        }

        try? context.save()
    }

    private struct Moment {
        var daysAgo: Int
        var hour: Int
        var minute: Int
        var text: String
        var insight: String
        var vector: MomentVector
        var sphere: LifeSphere
    }

    private static let moments: [Moment] = [
        Moment(daysAgo: 0, hour: 9, minute: 15, text: "Wrote the first draft of a product brief for a new feature", insight: "When I start with the question 'why', everything becomes clearer", vector: .course, sphere: .career),
        Moment(daysAgo: 1, hour: 21, minute: 30, text: "Spent two hours scrolling social media with no purpose", insight: "Fatigue is a trigger. Need an evening ritual", vector: .drift, sphere: .mindset),
        Moment(daysAgo: 5, hour: 14, minute: 0, text: "Completed the first module of the data analytics course", insight: "Consistency in small things leads to growth in big ones", vector: .course, sphere: .skills),
        Moment(daysAgo: 8, hour: 19, minute: 45, text: "Avoided a difficult conversation with a colleague", insight: "Avoidance compounds. Time to schedule a meeting", vector: .drift, sphere: .relationships),
        Moment(daysAgo: 0, hour: 11, minute: 5, text: "Asked why a feature exists before opening the editor", insight: "The question slowed me down in a useful way", vector: .course, sphere: .career),
        Moment(daysAgo: 2, hour: 10, minute: 20, text: "Chose the user problem before the solution", insight: "Direction got clearer once I named the person it helps", vector: .course, sphere: .career),
        Moment(daysAgo: 3, hour: 16, minute: 10, text: "Said no to an extra meeting that was not on my course", insight: "A small no protected the hour I needed", vector: .course, sphere: .career),
        Moment(daysAgo: 4, hour: 15, minute: 40, text: "Joined a call I did not need and lost the afternoon", insight: "Autopilot still shows up as politeness", vector: .drift, sphere: .career),
        Moment(daysAgo: 6, hour: 9, minute: 5, text: "Rewrote my lighthouse in one sentence", insight: "A shorter direction is easier to steer by", vector: .course, sphere: .career),
        Moment(daysAgo: 9, hour: 18, minute: 15, text: "Reviewed a product decision with a teammate", insight: "Talking it through showed the real tradeoff", vector: .course, sphere: .career),
        Moment(daysAgo: 2, hour: 13, minute: 0, text: "Practiced a SQL filter for fifteen minutes", insight: "Short practice still counts", vector: .course, sphere: .skills),
        Moment(daysAgo: 3, hour: 12, minute: 30, text: "Compared two product metrics before making a call", insight: "The gap was smaller than I feared", vector: .course, sphere: .skills),
        Moment(daysAgo: 4, hour: 20, minute: 10, text: "Opened a tutorial and never started it", insight: "Saving it for later was another form of drift", vector: .drift, sphere: .skills),
        Moment(daysAgo: 6, hour: 11, minute: 45, text: "Sketched one user flow on paper", insight: "Drawing made the missing step obvious", vector: .course, sphere: .skills),
        Moment(daysAgo: 2, hour: 19, minute: 0, text: "Cooked a real meal instead of skipping it", insight: "Rest can be a conscious choice", vector: .course, sphere: .health),
        Moment(daysAgo: 3, hour: 7, minute: 40, text: "Went for a short walk before work", insight: "The morning felt more like mine", vector: .course, sphere: .health),
        Moment(daysAgo: 6, hour: 22, minute: 15, text: "Stayed up scrolling when I had planned to sleep", insight: "The drift started when I was tired", vector: .drift, sphere: .health),
        Moment(daysAgo: 4, hour: 8, minute: 50, text: "Named the fear before I started the hard task", insight: "Seeing it made it smaller", vector: .course, sphere: .mindset),
        Moment(daysAgo: 9, hour: 21, minute: 5, text: "Told myself I would start tomorrow, again", insight: "Tomorrow was a way to avoid discomfort", vector: .drift, sphere: .mindset),
        Moment(daysAgo: 3, hour: 17, minute: 25, text: "Checked in with a teammate instead of guessing", insight: "The conversation was shorter than the worry", vector: .course, sphere: .relationships)
    ]
}
