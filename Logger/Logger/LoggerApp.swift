import SwiftUI
import Combine
import PartialSheet

@main
struct LoggerApp: App {
    @StateObject private var store = LoggerStore()
    
    let sheetManager = PartialSheetManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(sheetManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var store: LoggerStore
    @EnvironmentObject var sheetManager: PartialSheetManager
    
    var body: some View {
        VStack(spacing: 0) {
            EntryList(entries: store.state.entries)
                .environmentObject(sheetManager)
            ComposerView(onSubmit: handleSubmit)
                .padding()
        }
        .addPartialSheet()
        .onReceive(NotificationCenter.default.publisher(for: .entryDelete), perform: handleDelete)
        .onReceive(NotificationCenter.default.publisher(for: .entrySearchGoogle), perform: handleSearchGoogle)
        .onReceive(NotificationCenter.default.publisher(for: .entrySearchWikipedia), perform: handleSearchWikipedia)
    }
    
    func handleSubmit(text: String) {
        store.entryCreate(text: text, color: 0)
    }
    
    func handleDelete(_ publisher: NotificationCenter.Publisher.Output) {
        guard let entry = publisher.object as? Entry else { return }
        store.entryDelete(id: entry.id)
    }
    
    func handleSearchGoogle(_ publisher: NotificationCenter.Publisher.Output) {
        guard let entry = publisher.object as? Entry else { return }
        print("not implemented:", entry)
    }
    
    func handleSearchWikipedia(_ publisher: NotificationCenter.Publisher.Output) {
        guard let entry = publisher.object as? Entry else { return }
        print("not implemented:", entry)
    }
}
