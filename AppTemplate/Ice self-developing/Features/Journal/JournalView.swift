import SwiftUI

struct JournalView: View {
    @Environment(AppStore.self) private var store
    @State private var vectorFilter: MomentVector?
    @State private var sphereFilter: LifeSphere?

    var body: some View {
        @Bindable var store = store
        NavigationStack(path: $store.journalPath) {
            ScreenContainer {
                VStack(alignment: .leading, spacing: 12) {
                    header
                    filters
                    if filtered.isEmpty {
                        ContentUnavailableView {
                            Label(
                                store.sortedEntries.isEmpty ? "No moments yet" : "Nothing matches",
                                systemImage: "book.closed"
                            )
                        } description: {
                            Text(store.sortedEntries.isEmpty ? "Notice one choice today." : "Try another filter.")
                        }
                        .foregroundStyle(Theme.secondaryText)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filtered) { entry in
                                    JournalCard(entry: entry)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: JournalRoute.self) { _ in
                NewMomentView()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Journal")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                Text("Drift & Course")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer()
            PlusButton {
                store.openNewMoment()
            }
        }
        .padding(.horizontal, 20)
    }

    private var filters: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "All", isSelected: vectorFilter == nil) { vectorFilter = nil }
                    FilterChip(title: "Course", isSelected: vectorFilter == .course) { vectorFilter = .course }
                    FilterChip(title: "Drift", isSelected: vectorFilter == .drift) { vectorFilter = .drift }
                }
                .padding(.horizontal, 20)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "All", isSelected: sphereFilter == nil) { sphereFilter = nil }
                    ForEach(LifeSphere.allCases) { sphere in
                        FilterChip(title: sphere.rawValue, isSelected: sphereFilter == sphere) {
                            sphereFilter = sphere
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var filtered: [JournalEntry] {
        store.sortedEntries.filter { entry in
            let vectorMatches = vectorFilter == nil || entry.vector == vectorFilter
            let sphereMatches = sphereFilter == nil || entry.sphere == sphereFilter
            return vectorMatches && sphereMatches
        }
    }
}

private struct JournalCard: View {
    var entry: JournalEntry

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(entry.vector.rawValue)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(entry.vector == .course ? Theme.accent : Theme.cardRaised))
                    Text(entry.sphere.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.secondaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().stroke(Theme.border, lineWidth: 1))
                    Spacer()
                    Text(DateHelpers.journalStamp(entry.createdAt))
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                }
                Text(entry.text)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                if !entry.insight.isEmpty {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(Theme.warmEnd)
                        Text(entry.insight)
                            .font(.subheadline)
                            .foregroundStyle(Theme.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}

struct NewMomentView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var insight = ""
    @State private var vector: MomentVector = .course
    @State private var sphere: LifeSphere = .career

    private var canSave: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !insight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScreenContainer {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Theme.accent)
                    }
                    .buttonStyle(.plain)
                    Text("New Moment")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionKicker(title: "WHAT HAPPENED")
                        FieldBox(text: $text, placeholder: "Describe the moment...", axis: .vertical)
                        SectionKicker(title: "VECTOR")
                        HStack(spacing: 12) {
                            vectorButton(.course, symbol: "flame.fill")
                            vectorButton(.drift, symbol: "water.waves")
                        }
                        SectionKicker(title: "SPHERE")
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], alignment: .leading, spacing: 8) {
                            ForEach(LifeSphere.allCases) { item in
                                FilterChip(title: item.rawValue, isSelected: sphere == item) {
                                    sphere = item
                                }
                            }
                        }
                        SectionKicker(title: "INSIGHT")
                        FieldBox(text: $insight, placeholder: "What did I realize...", axis: .vertical)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                PrimaryButton(title: "Save Moment", systemImage: "flame.fill", style: .warm, isEnabled: canSave) {
                    store.addMoment(text: text, insight: insight, vector: vector, sphere: sphere)
                    dismiss()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func vectorButton(_ value: MomentVector, symbol: String) -> some View {
        let selected = vector == value
        return Button {
            vector = value
        } label: {
            Label(value.rawValue, systemImage: symbol)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(selected ? Theme.accent : Theme.card)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(selected ? Color.clear : Theme.border, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}
