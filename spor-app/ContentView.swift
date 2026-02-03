import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ProgramView()
                .tabItem {
                    Label("Programım", systemImage: "figure.run")
                }
                .tag(0)
            
            DietView()
                .tabItem {
                    Label("Diyet", systemImage: "fork.knife")
                }
                .tag(1)
        }
        .accentColor(.red) // Change accent color to red for better contrast with the theme
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [ProgramEntry.self, DietEntry.self], inMemory: true)
}
