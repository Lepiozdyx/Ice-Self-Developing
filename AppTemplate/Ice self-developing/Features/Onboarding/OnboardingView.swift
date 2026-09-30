import SwiftUI

struct OnboardingView: View {
    @Environment(AppStore.self) private var store
    @State private var page = 0
    @State private var lighthouseName = ""
    @State private var why = ""
    @State private var skills = OnboardingSkill.defaults

    private let suggestions = [
        "Become a Product Manager",
        "Move into UX Design",
        "Grow in my current career"
    ]

    var body: some View {
        ScreenContainer {
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                ZStack {
                    switch page {
                    case 0: welcome
                    case 1: notice
                    case 2: lighthouse
                    case 3: ratings
                    default: summary
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .id(page)
                .animation(.easeInOut(duration: 0.25), value: page)
                footer
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
        }
    }

    private var header: some View {
        ZStack {
            PageDots(count: 5, index: page)
            HStack {
                if page > 0 {
                    BackCircleButton { page -= 1 }
                } else {
                    Color.clear.frame(width: 36, height: 36)
                }
                Spacer()
                Text("\(page + 1)/5")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.secondaryText)
            }
        }
    }

    private var footer: some View {
        PrimaryButton(
            title: footerTitle,
            systemImage: page == 4 ? "flame.fill" : "arrow.right",
            style: page == 4 ? .warm : .blue,
            isEnabled: page != 2 || !lighthouseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ) {
            advance()
        }
        .padding(.top, 8)
    }

    private var footerTitle: String {
        switch page {
        case 0: "Set My Course"
        case 2: "Set My Lighthouse"
        case 4: "Enter My Course"
        default: "Continue"
        }
    }

    private var welcome: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Image("onb")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 230)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                SectionKicker(title: "ICE SELF-DEVELOPING")
                Text("Don't drift.\nSet your course.")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                Text("The current can carry you anywhere.\nYou can choose where you're going.")
                    .font(.body)
                    .foregroundStyle(Theme.secondaryText)
                VStack(alignment: .leading, spacing: 14) {
                    bullet("location.north.circle", "Notice your choices — not just your tasks")
                    bullet("light.beacon.max.fill", "Set a direction, not a deadline")
                    bullet("flame.fill", "Melt the ice one warm step at a time")
                }
                .padding(.top, 6)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }

    private var notice: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Notice the moments\nthat shape your direction.")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                Text("Every day holds both. The goal isn't to eliminate drift — it's to notice it.")
                    .font(.body)
                    .foregroundStyle(Theme.secondaryText)
                HStack(spacing: 12) {
                    chartCard(title: "wandering...", isCourse: false)
                    chartCard(title: "→ lighthouse", isCourse: true)
                }
                HStack(alignment: .top, spacing: 12) {
                    infoCard(
                        symbol: "cube",
                        tint: Theme.ice,
                        title: "Drift",
                        text: "Going with the current on autopilot. Not wrong — just unconscious."
                    )
                    infoCard(
                        symbol: "flame.fill",
                        tint: Theme.warmEnd,
                        title: "Course",
                        text: "A conscious choice. Moving toward something that matters."
                    )
                }
                SurfaceCard {
                    Text("\"Every conscious choice is a small step toward the life you want.\"")
                        .font(.body)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
        }
    }

    private var lighthouse: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                LighthouseGlyph()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                Text("Where do you want to go?")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                Text("Your Lighthouse is a direction, not a deadline. You can refine it anytime.")
                    .font(.body)
                    .foregroundStyle(Theme.secondaryText)
                SectionKicker(title: "MY LIGHTHOUSE")
                FieldBox(text: $lighthouseName, placeholder: "Become a Product Manager")
                suggestionChips
                SectionKicker(title: "WHY DOES THIS MATTER? (optional)")
                FieldBox(
                    text: $why,
                    placeholder: "I want to build products that help people and take responsibility for their direction...",
                    axis: .vertical
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }

    private var ratings: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Know where you're starting.")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                Text("Rate your current level in these areas. Your course gets clearer when you see the gap.")
                    .font(.body)
                    .foregroundStyle(Theme.secondaryText)
                ForEach(skills.indices, id: \.self) { index in
                    skillCard(index: index)
                }
                SurfaceCard {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(Theme.warmEnd)
                        Text("We'll use these gaps to suggest practical Warm Steps. You can adjust all skills inside the app.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }

    private var summary: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("You don't need to change\neverything today.")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                Text("Start with one warm step.")
                    .font(.body)
                    .foregroundStyle(Theme.secondaryText)
                SurfaceCard {
                    Label(lighthouseName, systemImage: "light.beacon.max.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                SurfaceCard {
                    HStack {
                        Label(featuredSkill.name, systemImage: "cube")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Spacer()
                        Text("gap to close")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
                SurfaceCard(stroke: Theme.warmEnd.opacity(0.7)) {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Today's Warm Step", systemImage: "flame.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.warmEnd)
                        Text(featuredStep.title)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                }
                SectionKicker(title: "YOUR DAILY RHYTHM")
                HStack(spacing: 12) {
                    rhythmCard(symbol: "sun.horizon.fill", tint: Theme.warmEnd, title: "Morning Spark", text: "Choose what matters today.")
                    rhythmCard(symbol: "moon.fill", tint: Theme.ice, title: "Evening Honesty", text: "Look back without judgment.")
                }
                SurfaceCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\"Small conscious choices melt the ice.\"")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                        Text("Ice Self-Developing")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }

    private var suggestionChips: some View {
        FlowChips(items: suggestions) { item in
            lighthouseName = item
        }
    }

    private var featuredSkill: OnboardingSkill {
        skills.enumerated().max { lhs, rhs in
            if lhs.element.gap == rhs.element.gap {
                return lhs.offset > rhs.offset
            }
            return lhs.element.gap < rhs.element.gap
        }?.element ?? skills[0]
    }

    private var featuredStep: WarmStepTemplate {
        WarmStepLibrary.featuredStep(for: featuredSkill.name)
    }

    private func advance() {
        if page < 4 {
            page += 1
        } else {
            store.completeOnboarding(lighthouse: lighthouseName, why: why, skills: skills)
        }
    }

    private func bullet(_ symbol: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(Theme.accent)
                .frame(width: 22)
            Text(text)
                .foregroundStyle(.white)
                .font(.subheadline)
        }
    }

    private func chartCard(title: String, isCourse: Bool) -> some View {
        SurfaceCard {
            VStack(spacing: 10) {
                if isCourse {
                    CourseSketch()
                } else {
                    DriftSketch()
                }
                Text(title)
                    .font(.caption)
                    .foregroundStyle(isCourse ? Theme.warmEnd : Theme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
        }
    }

    private func infoCard(symbol: String, tint: Color, title: String, text: String) -> some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: symbol)
                    .foregroundStyle(tint)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(text)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
            }
        }
    }

    private func skillCard(index: Int) -> some View {
        let skill = skills[index]
        return SurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(skill.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Text("gap \(skill.gap)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.warmEnd)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Theme.warmEnd.opacity(0.16)))
                }
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                        LevelStepper(value: skill.current) { skills[index].current = $0 }
                    }
                    Image(systemName: "arrow.right")
                        .foregroundStyle(Theme.secondaryText)
                        .padding(.top, 16)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                        LevelStepper(value: skill.target) { skills[index].target = $0 }
                    }
                }
                MeterBar(fraction: Double(skill.current) / 5)
            }
        }
    }

    private func rhythmCard(symbol: String, tint: Color, title: String, text: String) -> some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: symbol)
                    .foregroundStyle(tint)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(text)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct FlowChips: View {
    var items: [String]
    var onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                chip(items[0])
                chip(items[1])
            }
            chip(items[2])
        }
    }

    private func chip(_ title: String) -> some View {
        Button {
            onSelect(title)
        } label: {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().fill(Theme.cardRaised))
                .overlay(Capsule().stroke(Theme.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct LighthouseGlyph: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.warmEnd.opacity(0.18))
                .frame(width: 86, height: 86)
                .blur(radius: 8)
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Theme.warmEnd)
                    .frame(width: 22, height: 16)
                    .shadow(color: Theme.warmEnd.opacity(0.8), radius: 10)
                Rectangle()
                    .fill(Theme.accent)
                    .frame(width: 16, height: 8)
                Rectangle()
                    .fill(Theme.accentDeep)
                    .frame(width: 18, height: 28)
                Rectangle()
                    .fill(Theme.accent)
                    .frame(width: 28, height: 8)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct DriftSketch: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.move(to: CGPoint(x: 8, y: size.height * 0.32))
            path.addCurve(
                to: CGPoint(x: size.width - 12, y: size.height * 0.48),
                control1: CGPoint(x: size.width * 0.28, y: size.height * 0.05),
                control2: CGPoint(x: size.width * 0.62, y: size.height * 0.95)
            )
            context.stroke(
                path,
                with: .color(Theme.secondaryText.opacity(0.85)),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 5])
            )
            for point in [
                CGPoint(x: 18, y: size.height * 0.28),
                CGPoint(x: size.width * 0.48, y: size.height * 0.72),
                CGPoint(x: size.width - 20, y: size.height * 0.42)
            ] {
                let dot = Path(ellipseIn: CGRect(x: point.x, y: point.y, width: 7, height: 7))
                context.fill(dot, with: .color(Theme.secondaryText))
            }
        }
    }
}

private struct CourseSketch: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.move(to: CGPoint(x: 16, y: size.height * 0.78))
            path.addLine(to: CGPoint(x: size.width - 18, y: size.height * 0.22))
            context.stroke(path, with: .color(Theme.accent), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            for (index, point) in [
                CGPoint(x: 16, y: size.height * 0.78),
                CGPoint(x: size.width * 0.42, y: size.height * 0.55),
                CGPoint(x: size.width * 0.68, y: size.height * 0.38)
            ].enumerated() {
                let rect = CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8)
                context.fill(Path(ellipseIn: rect), with: .color(index == 0 ? Theme.ice : Theme.accent))
            }
            let end = CGRect(x: size.width - 26, y: size.height * 0.22 - 8, width: 16, height: 16)
            context.fill(Path(ellipseIn: end), with: .color(Theme.warmEnd))
        }
    }
}
