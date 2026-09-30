import SwiftUI
import SwiftData

@MainActor
struct Ice_self_developingApp: View {
    private let container: ModelContainer
    @State private var store: AppStore

    init() {
        let container = AppDatabase.makeContainer()
        if AppConfig.useMockSeed {
            MockSeed.applyIfNeeded(context: container.mainContext)
        }
        let store = AppStore(context: container.mainContext)
        store.prepareForLaunch()
        self.container = container
        _store = State(initialValue: store)
    }

    var body: some View {
        RootView()
            .environment(store)
            .preferredColorScheme(.dark)
            .tint(Theme.accent)
            .modelContainer(container)
    }
}

enum AppDatabase {
    static func makeContainer() -> ModelContainer {
        let schema = Schema([
            UserProfile.self,
            LighthouseGoal.self,
            Checkpoint.self,
            Skill.self,
            WarmStep.self,
            JournalEntry.self,
            MorningRitual.self,
            EveningRitual.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create the local store: \(error)")
        }
    }
}
