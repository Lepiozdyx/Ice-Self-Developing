import SwiftUI

struct HelmView: View {
    @Environment(AppStore.self) private var store
    @State private var showReminders = false

    var body: some View {
        @Bindable var store = store
        NavigationStack(path: $store.helmPath) {
            ScreenContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        topBar
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text("Welcome back, \(store.displayName)")
                                    .font(.largeTitle.weight(.bold))
                                    .foregroundStyle(.white)
                                Image(systemName: "location.north.circle.fill")
                                    .foregroundStyle(Theme.accent)
                            }
                            Text(DateHelpers.helmString(.now))
                                .font(.subheadline)
                                .foregroundStyle(Theme.secondaryText)
                        }
                        temperatureCard
                        courseCard
                        SectionKicker(title: "RITUALS")
                        HStack(spacing: 12) {
                            ritualCard(kind: .morning, symbol: "sun.max.fill", tint: Theme.warmEnd, title: "Morning", subtitle: "spark")
                            ritualCard(kind: .evening, symbol: "moon.fill", tint: Theme.ice, title: "Evening", subtitle: "honesty")
                        }
                        SectionKicker(title: "QUICK ACTIONS")
                        HStack(spacing: 10) {
                            quickPill(title: "My Course", symbol: "light.beacon.max") { store.openCourse() }
                            quickPill(title: "Statistics", symbol: "chart.bar") { store.openStatistics() }
                        }
                        Button {
                            store.openNewMoment()
                        } label: {
                            Label("Log a moment", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(Theme.card))
                                .overlay(Capsule().stroke(Theme.warmEnd.opacity(0.7), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: HelmRoute.self) { route in
                switch route {
                case .rituals(let kind):
                    RitualsView(initialKind: kind)
                }
            }
        }
        .sheet(isPresented: $showReminders) {
            RemindersSheet()
                .presentationDetents([.height(230)])
                .presentationDragIndicator(.visible)
        }
    }

    private var topBar: some View {
        HStack {
            Label(store.authorship.title, systemImage: store.authorship.symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().fill(Theme.accent.opacity(0.22)))
                .overlay(Capsule().stroke(Theme.accent.opacity(0.45), lineWidth: 1))
            Spacer()
            Button {
                showReminders = true
            } label: {
                Image(systemName: store.remindersEnabled ? "bell.fill" : "bell")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Theme.cardRaised))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Reminders")
        }
    }

    private var temperatureCard: some View {
        SurfaceCard {
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionKicker(title: "WILL TEMPERATURE")
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(store.willTemperature)")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("°")
                            .font(.title.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    TemperatureScale(value: store.willTemperature)
                }
                Spacer(minLength: 8)
                IcebergMark(
                    melt: Double(store.willTemperature) / 100,
                    warmth: Double(store.willTemperature) / 100
                )
            }
        }
    }

    private var courseCard: some View {
        Button {
            store.openRitual(.morning)
        } label: {
            SurfaceCard(stroke: Theme.warmEnd.opacity(0.55)) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("COURSE OF THE DAY", systemImage: "circle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.warmEnd)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Theme.warmEnd, Theme.warmEnd)
                    Text(store.courseOfDay.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    if let subtitle = store.courseOfDay.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func ritualCard(kind: RitualKind, symbol: String, tint: Color, title: String, subtitle: String) -> some View {
        Button {
            store.openRitual(kind)
        } label: {
            SurfaceCard {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: symbol)
                        .foregroundStyle(tint)
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    private func quickPill(title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Capsule().fill(Theme.card))
                .overlay(Capsule().stroke(Theme.accent.opacity(0.45), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct TemperatureScale: View {
    var value: Int

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let fill = max(28, width * CGFloat(value) / 100)
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.track)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Theme.ice, Theme.accent, Theme.warmEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: fill)
                HStack {
                    Image(systemName: "snowflake")
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(.leading, 8)
                    Spacer()
                }
                Image(systemName: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .offset(x: min(width - 22, fill - 16))
            }
        }
        .frame(height: 18)
        .accessibilityLabel("Will temperature \(value)")
    }
}
