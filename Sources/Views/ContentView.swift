import SwiftUI

struct ContentView: View {
    @StateObject private var store = Store()
    @State private var selectedKidId: String?
    @State private var selectedDate = Date()
    @State private var showWeek = false
    
    var body: some View {
        TabView {
            KidsView(store: store, selectedKidId: $selectedKidId, selectedDate: $selectedDate, showWeek: $showWeek)
                .tabItem { Label("Chores", systemImage: "list.bullet") }
            HistoryView(store: store)
                .tabItem { Label("History", systemImage: "clock") }
            TemplatesView(store: store)
                .tabItem { Label("Chore List", systemImage: "gearshape") }
        }
        .onAppear {
            if selectedKidId == nil && !store.kids.isEmpty {
                selectedKidId = store.kids.first?.id
            }
        }
    }
}
