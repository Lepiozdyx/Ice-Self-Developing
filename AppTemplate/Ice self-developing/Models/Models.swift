import Foundation
import SwiftData

enum MeasurementUnits: String, CaseIterable, Identifiable {
    case metric = "Metric"
    case imperial = "Imperial"

    var id: String { rawValue }
}

enum LifeSphere: String, CaseIterable, Identifiable {
    case career = "Career"
    case skills = "Skills"
    case income = "Income"
    case health = "Health"
    case relationships = "Relationships"
    case mindset = "Mindset"
    case environment = "Environment"

    var id: String { rawValue }
}

enum MomentVector: String, CaseIterable, Identifiable {
    case course = "Course"
    case drift = "Drift"

    var id: String { rawValue }
}

enum StepPriority: String, CaseIterable, Identifiable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var id: String { rawValue }

    static func from(gap: Int) -> StepPriority {
        switch gap {
        case 3...: .high
        case 2: .medium
        default: .low
        }
    }
}

enum AuthorshipLevel: Int, CaseIterable, Identifiable {
    case iceSheet = 0
    case awakening
    case rower
    case navigator
    case captain
    case lighthouse

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .iceSheet: "Ice Sheet"
        case .awakening: "Awakening"
        case .rower: "Rower"
        case .navigator: "Navigator"
        case .captain: "Captain"
        case .lighthouse: "Lighthouse"
        }
    }

    var symbol: String {
        switch self {
        case .iceSheet: "cube"
        case .awakening: "water.waves"
        case .rower: "sailboat"
        case .navigator: "location.north.circle"
        case .captain: "anchor"
        case .lighthouse: "light.beacon.max"
        }
    }
}

enum AuthorScore {
    static func label(for score: Int) -> String {
        switch score {
        case 0...1: "Drifted"
        case 2...3: "Mostly drifted"
        case 4...6: "Mixed — drifted some"
        case 7...8: "Mostly on course"
        default: "Author of the day"
        }
    }

    static func temperatureDelta(for score: Int) -> Int {
        switch score {
        case 0...2: -2
        case 3...4: 0
        case 5...6: 3
        case 7...8: 6
        default: 10
        }
    }

    static func iceDelta(for score: Int) -> Double {
        if score >= 7 { return 2 }
        if score >= 4 { return 1 }
        return 0
    }
}

enum AppTab: Hashable {
    case helm
    case course
    case journal
    case statistics
    case profile
}

enum RitualKind: String, Hashable, CaseIterable, Identifiable {
    case morning
    case evening

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning: "Morning Spark"
        case .evening: "Evening Honesty"
        }
    }
}

enum HelmRoute: Hashable {
    case rituals(RitualKind)
}

enum JournalRoute: Hashable {
    case newMoment
}

@Model
final class UserProfile {
    var name: String
    var remindersEnabled: Bool
    var unitsRaw: String
    var onboardingCompleted: Bool
    var willTemperature: Int
    var iceMelted: Double
    var iceAtWeekStart: Double
    var weekStart: Date
    var helmStreak: Int
    var lastHelmDay: Date?
    var lastDecayDay: Date?

    init(
        name: String = "User",
        remindersEnabled: Bool = false,
        units: MeasurementUnits = .metric,
        onboardingCompleted: Bool = false,
        willTemperature: Int = 40,
        iceMelted: Double = 0,
        iceAtWeekStart: Double = 0,
        weekStart: Date = .now,
        helmStreak: Int = 0,
        lastHelmDay: Date? = nil,
        lastDecayDay: Date? = nil
    ) {
        self.name = name
        self.remindersEnabled = remindersEnabled
        self.unitsRaw = units.rawValue
        self.onboardingCompleted = onboardingCompleted
        self.willTemperature = willTemperature
        self.iceMelted = iceMelted
        self.iceAtWeekStart = iceAtWeekStart
        self.weekStart = weekStart
        self.helmStreak = helmStreak
        self.lastHelmDay = lastHelmDay
        self.lastDecayDay = lastDecayDay
    }

    var units: MeasurementUnits {
        get { MeasurementUnits(rawValue: unitsRaw) ?? .metric }
        set { unitsRaw = newValue.rawValue }
    }
}

@Model
final class LighthouseGoal {
    var name: String
    var why: String
    var pointA: String
    var pointB: String
    @Relationship(deleteRule: .cascade, inverse: \Checkpoint.goal)
    var checkpoints: [Checkpoint] = []

    init(name: String, why: String, pointA: String, pointB: String) {
        self.name = name
        self.why = why
        self.pointA = pointA
        self.pointB = pointB
        self.checkpoints = []
    }

    var orderedCheckpoints: [Checkpoint] {
        checkpoints.sorted { $0.sortOrder < $1.sortOrder }
    }
}

@Model
final class Checkpoint {
    var title: String
    var sortOrder: Int
    var goal: LighthouseGoal?

    init(title: String, sortOrder: Int, goal: LighthouseGoal? = nil) {
        self.title = title
        self.sortOrder = sortOrder
        self.goal = goal
    }
}

@Model
final class Skill {
    var name: String
    var currentLevel: Int
    var targetLevel: Int
    var createdAt: Date

    init(name: String, currentLevel: Int, targetLevel: Int, createdAt: Date = .now) {
        self.name = name
        self.currentLevel = min(5, max(1, currentLevel))
        self.targetLevel = min(5, max(1, targetLevel))
        self.createdAt = createdAt
    }

    var gap: Int {
        max(0, targetLevel - currentLevel)
    }

    var priority: StepPriority {
        StepPriority.from(gap: gap)
    }
}

@Model
final class WarmStep {
    var title: String
    var skillName: String
    var priorityRaw: String
    var isDone: Bool
    var createdAt: Date

    init(title: String, skillName: String, priority: StepPriority, isDone: Bool = false, createdAt: Date = .now) {
        self.title = title
        self.skillName = skillName
        self.priorityRaw = priority.rawValue
        self.isDone = isDone
        self.createdAt = createdAt
    }

    var priority: StepPriority {
        get { StepPriority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }
}

@Model
final class JournalEntry {
    var text: String
    var insight: String
    var vectorRaw: String
    var sphereRaw: String
    var createdAt: Date

    init(text: String, insight: String, vector: MomentVector, sphere: LifeSphere, createdAt: Date = .now) {
        self.text = text
        self.insight = insight
        self.vectorRaw = vector.rawValue
        self.sphereRaw = sphere.rawValue
        self.createdAt = createdAt
    }

    var vector: MomentVector {
        MomentVector(rawValue: vectorRaw) ?? .course
    }

    var sphere: LifeSphere {
        LifeSphere(rawValue: sphereRaw) ?? .career
    }
}

@Model
final class MorningRitual {
    var dayStart: Date
    var intention: String
    var warmStep: String
    var anchor: String
    var createdAt: Date

    init(dayStart: Date, intention: String, warmStep: String, anchor: String, createdAt: Date = .now) {
        self.dayStart = dayStart
        self.intention = intention
        self.warmStep = warmStep
        self.anchor = anchor
        self.createdAt = createdAt
    }
}

@Model
final class EveningRitual {
    var dayStart: Date
    var authorScore: Int
    var driftNote: String
    var proudNote: String
    var lesson: String
    var createdAt: Date

    init(
        dayStart: Date,
        authorScore: Int,
        driftNote: String,
        proudNote: String,
        lesson: String,
        createdAt: Date = .now
    ) {
        self.dayStart = dayStart
        self.authorScore = authorScore
        self.driftNote = driftNote
        self.proudNote = proudNote
        self.lesson = lesson
        self.createdAt = createdAt
    }
}
