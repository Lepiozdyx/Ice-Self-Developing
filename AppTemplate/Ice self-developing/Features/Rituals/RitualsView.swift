import SwiftUI

struct RitualsView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var kind: RitualKind
    @State private var intention = ""
    @State private var warmStep = ""
    @State private var anchor = ""
    @State private var score = 5
    @State private var drift = ""
    @State private var proud = ""
    @State private var lesson = ""

    init(initialKind: RitualKind) {
        _kind = State(initialValue: initialKind)
    }

    var body: some View {
        ScreenContainer {
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                segment
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if kind == .morning {
                            morningContent
                        } else {
                            eveningContent
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 16)
                }
                bottomButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }

    private var header: some View {
        ZStack {
            Text("RITUALS OF AWARENESS")
                .font(.caption.weight(.semibold))
                .tracking(1.2)
                .foregroundStyle(Theme.secondaryText)
            HStack {
                BackCircleButton { dismiss() }
                Spacer()
            }
        }
    }

    private var segment: some View {
        HStack(spacing: 6) {
            segmentButton(.morning, symbol: "sun.max.fill")
            segmentButton(.evening, symbol: "moon.fill")
        }
        .padding(4)
        .background(Theme.card, in: Capsule())
    }

    private func segmentButton(_ value: RitualKind, symbol: String) -> some View {
        let selected = kind == value
        let done = value == .morning ? store.morningRitual() != nil : store.eveningRitual() != nil
        return Button {
            kind = value
        } label: {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                Text(value == .morning ? "Morning Spark" : "Evening Honesty")
                if done {
                    Circle().fill(Theme.complete).frame(width: 6, height: 6)
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                if selected {
                    Capsule().fill(Theme.accent)
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var morningContent: some View {
        if let ritual = store.morningRitual() {
            completeHeader(
                symbol: "sun.horizon.fill",
                tint: Theme.warmEnd,
                title: "Morning Spark",
                caption: DateHelpers.ritualDayString(.now)
            )
            answerCard(kicker: "WHAT MATTERS MOST TODAY", text: ritual.intention, emphasized: false)
            answerCard(kicker: "WARM STEP TOWARD MY COURSE", text: ritual.warmStep, emphasized: true)
            answerCard(kicker: "ANCHOR", text: ritual.anchor, emphasized: false)
            SurfaceCard {
                Text("Your intention is set. Morning Spark complete.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        } else {
            ritualIntro(
                symbol: "sun.horizon.fill",
                tint: Theme.warmEnd,
                title: "Morning Spark",
                caption: "1–2 min · Set your intention"
            )
            promptCard(number: 1, tint: Theme.accent, title: "What matters most to me today?", text: $intention, placeholder: "My main intention for today...")
            promptCard(number: 2, tint: Theme.warmEnd, title: "What is one warm step I'll take toward my course?", text: $warmStep, placeholder: "One concrete action today...")
            promptCard(number: 3, tint: Theme.accent, title: "My anchor for today", text: $anchor, placeholder: "Clarity · Patience · Courage...")
        }
    }

    @ViewBuilder
    private var eveningContent: some View {
        if let ritual = store.eveningRitual() {
            completeHeader(
                symbol: "moon.fill",
                tint: Theme.ice,
                title: "Evening Honesty",
                caption: DateHelpers.ritualDayString(.now)
            )
            SurfaceCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionKicker(title: "AUTHOR SCORE")
                    HStack(spacing: 14) {
                        Text("\(ritual.authorScore)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 64, height: 64)
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Theme.accent, lineWidth: 2))
                        VStack(alignment: .leading, spacing: 8) {
                            Text(AuthorScore.label(for: ritual.authorScore))
                                .font(.headline)
                                .foregroundStyle(.white)
                            MeterBar(fraction: Double(ritual.authorScore) / 10, tint: Theme.accent)
                        }
                    }
                }
            }
            answerCard(kicker: "WHERE I DRIFTED", text: ritual.driftNote, emphasized: false)
            answerCard(kicker: "PROUD OF", text: ritual.proudNote, emphasized: false)
            answerCard(kicker: "LESSON", text: ritual.lesson, emphasized: true)
        } else {
            ritualIntro(
                symbol: "moon.fill",
                tint: Theme.ice,
                title: "Evening Honesty",
                caption: "2–3 min · Honest look at your day"
            )
            SurfaceCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        numberBadge(1, tint: Theme.warmStart)
                        Text("Was I the author of my day?")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    HStack {
                        Text("Drift")
                            .foregroundStyle(Theme.warmEnd)
                        Spacer()
                        Text("Author")
                            .foregroundStyle(Theme.accent)
                    }
                    .font(.caption.weight(.semibold))
                    AuthorSlider(score: $score)
                }
            }
            promptCard(number: 2, tint: Theme.accent, title: "Where did I drift?", text: $drift, placeholder: "A moment of autopilot, avoidance, or distraction...")
            promptCard(number: 3, tint: Theme.accent, title: "What am I proud of today?", text: $proud, placeholder: "Even the smallest win counts...")
            promptCard(number: 4, tint: Theme.warmEnd, title: "What lesson am I taking with me?", text: $lesson, placeholder: "The key insight from today...")
        }
    }

    private var bottomButton: some View {
        let morningDone = store.morningRitual() != nil
        let eveningDone = store.eveningRitual() != nil
        let isComplete = kind == .morning ? morningDone : eveningDone
        return PrimaryButton(
            title: isComplete ? "Done" : (kind == .morning ? "Save Intention" : "Save"),
            systemImage: isComplete ? nil : (kind == .morning ? "sun.max" : "flame.fill"),
            style: kind == .evening ? .warm : .blue,
            isEnabled: isComplete || kind == .evening || !intention.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ) {
            if isComplete {
                dismiss()
                return
            }
            if kind == .morning {
                store.saveMorning(intention: intention, warmStep: warmStep, anchor: anchor)
            } else {
                store.saveEvening(score: score, drift: drift, proud: proud, lesson: lesson)
            }
        }
    }

    private func ritualIntro(symbol: String, tint: Color, title: String, caption: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                Text(caption)
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer()
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(tint)
                .frame(width: 48, height: 48)
                .background(Circle().fill(Theme.cardRaised))
        }
    }

    private func completeHeader(symbol: String, tint: Color, title: String, caption: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.cardRaised))
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    Label("Complete", systemImage: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.complete)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Theme.complete.opacity(0.16)))
                }
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer()
        }
    }

    private func answerCard(kicker: String, text: String, emphasized: Bool) -> some View {
        SurfaceCard(stroke: emphasized ? Theme.warmEnd.opacity(0.75) : Theme.border) {
            VStack(alignment: .leading, spacing: 8) {
                Text(kicker)
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(emphasized ? Theme.warmEnd : Theme.secondaryText)
                Text(text.isEmpty ? "—" : text)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
            }
        }
    }

    private func promptCard(number: Int, tint: Color, title: String, text: Binding<String>, placeholder: String) -> some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    numberBadge(number, tint: tint)
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                ZStack(alignment: .topLeading) {
                    if text.wrappedValue.isEmpty {
                        Text(placeholder)
                            .foregroundStyle(Theme.secondaryText.opacity(0.85))
                            .padding(.top, 8)
                            .padding(.leading, 4)
                            .allowsHitTesting(false)
                    }
                    TextField("", text: text, axis: .vertical)
                        .keyboardDoneButton()
                        .lineLimit(2...4)
                        .foregroundStyle(.white)
                }
                Rectangle()
                    .fill(Theme.border)
                    .frame(height: 1)
            }
        }
    }

    private func numberBadge(_ number: Int, tint: Color) -> some View {
        Text("\(number)")
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: 24, height: 24)
            .background(Circle().fill(tint))
    }
}

private struct AuthorSlider: View {
    @Binding var score: Int

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Theme.warmEnd, Theme.accent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 8)
                        .padding(.vertical, 10)
                    Circle()
                        .fill(Theme.warmEnd)
                        .frame(width: 28, height: 28)
                        .overlay(Circle().stroke(.white, lineWidth: 3))
                        .offset(x: thumbX(in: width))
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let ratio = min(1, max(0, value.location.x / width))
                            score = Int((ratio * 10).rounded())
                        }
                )
            }
            .frame(height: 28)
            HStack {
                ForEach([0, 2, 4, 6, 8, 10], id: \.self) { mark in
                    Text("\(mark)")
                        .frame(maxWidth: .infinity)
                }
            }
            .font(.caption2)
            .foregroundStyle(Theme.secondaryText)
            Text(AuthorScore.label(for: score))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.warmEnd)
        }
        .accessibilityElement()
        .accessibilityLabel("Author score")
        .accessibilityValue("\(score). \(AuthorScore.label(for: score))")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: score = min(10, score + 1)
            case .decrement: score = max(0, score - 1)
            default: break
            }
        }
    }

    private func thumbX(in width: CGFloat) -> CGFloat {
        let travel = max(0, width - 28)
        return travel * CGFloat(score) / 10
    }
}
