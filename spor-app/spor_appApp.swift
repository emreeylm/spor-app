import SwiftUI
import SwiftData

@main
struct spor_appApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ProgramEntry.self,
            DietEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
