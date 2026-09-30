import Foundation

struct WarmStepTemplate: Hashable {
    var title: String
    var skillName: String
    var priority: StepPriority
}

enum WarmStepLibrary {
    static let all: [WarmStepTemplate] = [
        WarmStepTemplate(title: "Complete an analytics course module", skillName: "Data Analytics", priority: .medium),
        WarmStepTemplate(title: "Analyze one product case study", skillName: "Data Analytics", priority: .medium),
        WarmStepTemplate(title: "Practice SQL for 15 minutes", skillName: "SQL / Python", priority: .medium),
        WarmStepTemplate(title: "Break down one product case study", skillName: "Product Thinking", priority: .medium),
        WarmStepTemplate(title: "Write a one-pager for a product idea", skillName: "Product Thinking", priority: .medium),
        WarmStepTemplate(title: "Read a PM blog post or book chapter", skillName: "Product Thinking", priority: .medium),
        WarmStepTemplate(title: "Spend 15 minutes on SQL practice", skillName: "SQL / Python", priority: .medium),
        WarmStepTemplate(title: "Complete one Kaggle exercise", skillName: "Data Analytics", priority: .medium),
        WarmStepTemplate(title: "Write a simple data query summary", skillName: "SQL / Python", priority: .medium),
        WarmStepTemplate(title: "Practice Software for 15 minutes", skillName: "Software", priority: .medium),
        WarmStepTemplate(title: "Find a learning resource on Software", skillName: "Software", priority: .medium),
        WarmStepTemplate(title: "Apply Software to a real project", skillName: "Software", priority: .medium),
        WarmStepTemplate(title: "Talk to a working PM", skillName: "Communication", priority: .medium),
        WarmStepTemplate(title: "Present an idea to a colleague", skillName: "Communication", priority: .medium),
        WarmStepTemplate(title: "Write a brief summary of a decision", skillName: "Communication", priority: .medium),
        WarmStepTemplate(title: "Read the Scrum Guide", skillName: "Agile / Scrum", priority: .low),
        WarmStepTemplate(title: "Attend or review a sprint retrospective", skillName: "Agile / Scrum", priority: .low),
        WarmStepTemplate(title: "Critique the UX of one app you use daily", skillName: "UX Fundamentals", priority: .low),
        WarmStepTemplate(title: "Sketch a wireframe for a feature", skillName: "UX Fundamentals", priority: .low)
    ]

    static func templates(for skillName: String) -> [WarmStepTemplate] {
        let trimmed = skillName.trimmingCharacters(in: .whitespacesAndNewlines)
        let matches = all.filter { $0.skillName.compare(trimmed, options: .caseInsensitive) == .orderedSame }
        if !matches.isEmpty {
            return matches
        }
        guard !trimmed.isEmpty else { return [] }
        return [
            WarmStepTemplate(title: "Practice \(trimmed) for 15 minutes", skillName: trimmed, priority: .medium),
            WarmStepTemplate(title: "Find a learning resource on \(trimmed)", skillName: trimmed, priority: .medium),
            WarmStepTemplate(title: "Apply \(trimmed) to a real project", skillName: trimmed, priority: .medium)
        ]
    }

    static func featuredStep(for skillName: String) -> WarmStepTemplate {
        templates(for: skillName).first
            ?? WarmStepTemplate(title: "Take one warm step today", skillName: skillName, priority: .medium)
    }
}
