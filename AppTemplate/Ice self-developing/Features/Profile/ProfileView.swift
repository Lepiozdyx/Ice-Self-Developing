import SwiftUI

struct ProfileView: View {
    @Environment(AppStore.self) private var store
    @State private var name = ""

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    SectionKicker(title: "SETTINGS")
                        .padding(.horizontal, 4)
                    settings
                    SectionKicker(title: "AUTHORSHIP LEVELS")
                        .padding(.horizontal, 4)
                    VStack(spacing: 8) {
                        ForEach(AuthorshipLevel.allCases) { level in
                            levelRow(level)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .onAppear { name = store.displayName }
    }

    private var header: some View {
        SurfaceCard {
            HStack(spacing: 14) {
                Image(systemName: "location.north.circle")
                    .font(.title)
                    .foregroundStyle(Theme.accent)
                    .frame(width: 64, height: 64)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.cardRaised))
                VStack(alignment: .leading, spacing: 6) {
                    Text(store.displayName)
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                    Label(store.authorship.title, systemImage: store.authorship.symbol)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Theme.accent.opacity(0.25)))
                    Text("\(store.helmDays) days at the helm")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                }
                Spacer()
            }
        }
    }

    private var settings: some View {
        SurfaceCard(padding: 0) {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Name")
                            .foregroundStyle(.white)
                        Text("Shown on the dashboard")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                    }
                    Spacer()
                    TextField("User", text: $name)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(Theme.accent)
                        .frame(maxWidth: 140)
                        .onChange(of: name) { _, newValue in
                            store.setName(newValue)
                        }
                }
                .padding(16)
                Divider().overlay(Theme.border)
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reminders")
                            .foregroundStyle(.white)
                        Text("For mindfulness rituals")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                    }
                    Spacer()
                    Toggle("Reminders", isOn: remindersBinding)
                        .labelsHidden()
                        .tint(Theme.accent)
                }
                .padding(16)
                Divider().overlay(Theme.border)
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Units")
                            .foregroundStyle(.white)
                        Text("Display format")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                    }
                    Spacer()
                    Menu {
                        ForEach(MeasurementUnits.allCases) { unit in
                            Button(unit.rawValue) {
                                store.setUnits(unit)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(store.units.rawValue)
                            Image(systemName: "chevron.down")
                                .font(.caption2.weight(.bold))
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                    }
                }
                .padding(16)
            }
        }
    }

    private var remindersBinding: Binding<Bool> {
        Binding(
            get: { store.remindersEnabled },
            set: { enabled in
                Task { await store.setRemindersEnabled(enabled) }
            }
        )
    }

    private func levelRow(_ level: AuthorshipLevel) -> some View {
        let current = store.authorship == level
        return HStack(spacing: 12) {
            Image(systemName: level.symbol)
                .foregroundStyle(tint(for: level))
                .frame(width: 28)
            Text(level.title)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
            Spacer()
            if current {
                Text("You're here")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Theme.accent))
            }
        }
        .padding(14)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(current ? Theme.accent : Theme.border, lineWidth: current ? 1.5 : 1)
        }
    }

    private func tint(for level: AuthorshipLevel) -> Color {
        switch level {
        case .iceSheet: Theme.ice
        case .awakening: Theme.accent
        case .rower: Theme.complete
        case .navigator: .white
        case .captain: Theme.secondaryText
        case .lighthouse: Theme.warmEnd
        }
    }
}

struct RemindersSheet: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reminders")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
            Text("A morning spark at 8:00 and evening honesty at 21:00.")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
            Toggle("Reminders", isOn: Binding(
                get: { store.remindersEnabled },
                set: { enabled in
                    Task { await store.setRemindersEnabled(enabled) }
                }
            ))
            .tint(Theme.accent)
            .foregroundStyle(.white)
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.background)
    }
}
