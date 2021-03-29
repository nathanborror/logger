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
                .background(Color(hex: 0xF9F9F9).ignoresSafeArea())
                .environmentObject(store)
                .environmentObject(sheetManager)
                .onOpenURL { url in
                    print(url)
                    if url.absoluteString.hasPrefix("logger:tag=") {
                        let tag = url.absoluteString.removePrefix("logger:tag=")
                        NotificationCenter.default.post(name: .itemSearch, object: tag)
                    }
//                    let original = FileManager.document(named: "data.logger")
//                    FileManager.replace(at: original, with: url)
//                    store.reload()
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var store: LoggerStore
    @EnvironmentObject var sheetManager: PartialSheetManager
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack(spacing: 0) {
            ItemList(items: store.state.items)
                .environmentObject(sheetManager)
            ComposerView()
                .padding()
        }
        .addPartialSheet()
        .onReceive(NotificationCenter.default.publisher(for: .itemSave), perform: handleSave)
        .onReceive(NotificationCenter.default.publisher(for: .itemDelete), perform: handleDelete)
        .onReceive(NotificationCenter.default.publisher(for: .itemSearch), perform: handleSearch)
        .onReceive(NotificationCenter.default.publisher(for: .itemSearchGoogle), perform: handleSearchGoogle)
        .onReceive(NotificationCenter.default.publisher(for: .itemSearchWikipedia), perform: handleSearchWikipedia)
    }
    
    func handleSave(_ publisher: NotificationCenter.Publisher.Output) {
        guard let item = publisher.object as? Item else { return }
        if item.id == 0 {
            store.itemCreate(text: item.text, color: item.color)
        } else {
            store.itemUpdate(id: item.id, text: item.text, color: item.color)
        }
    }
    
    func handleDelete(_ publisher: NotificationCenter.Publisher.Output) {
        guard let item = publisher.object as? Item else { return }
        store.itemDelete(id: item.id)
    }
    
    func handleSearch(_ publisher: NotificationCenter.Publisher.Output) {
        guard let query = publisher.object as? String else { return }
        store.itemSearch(query: query)
    }
    
    func handleSearchGoogle(_ publisher: NotificationCenter.Publisher.Output) {
        guard let item = publisher.object as? Item else { return }
        openURL(URL(string: "https://google.com/search?q=\(item.text)")!)
    }
    
    func handleSearchWikipedia(_ publisher: NotificationCenter.Publisher.Output) {
        guard let item = publisher.object as? Item else { return }
        openURL(URL(string: "https://google.com/search?q=\(item.text)+site:wikipedia.org")!)
    }
}
