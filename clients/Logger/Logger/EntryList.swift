import SwiftUI
import PartialSheet

struct EntryList: View {
    let entries: [Entry]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 2) {
                ForEach(entries, id: \.self) { entry in
                    EntryRow(entry: entry)
                        .flipUpsideDown()
                }
            }
            .padding(.horizontal, 16)
        }
        .flipUpsideDown()
    }
}

struct EntryRow: View {
    @EnvironmentObject var sheetManager: PartialSheetManager
    
    let entry: Entry
    
    @State var isShowingActions = false
    
    var body: some View {
        Text(entry.text)
            .padding(EdgeInsets(top: 11, leading: 18, bottom: 11, trailing: 18))
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(22)
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .onTapGesture {
                sheetManager.showPartialSheet({ print("dismiss") }) {
                    Form {
                        Section {
                            Button(action: handleGoogle) { Label(title: { Text("Google") }, icon: { Image(systemName: "magnifyingglass") }) }
                            Button(action: handleWikipedia) { Label(title: { Text("Wikipedia") }, icon: { Image(systemName: "book") }) }
                        }
                        Section {
                            Button(action: handleDelete) { Label(title: { Text("Delete") }, icon: { Image(systemName: "trash") }).foregroundColor(.red) }
                        }
                    }
                    .frame(height: 300)
                }
            }
    }
    
    func handleDelete() {
        isShowingActions = false
        NotificationCenter.default.post(name: .entryDelete, object: entry)
    }
    
    func handleGoogle() {
        isShowingActions = false
        NotificationCenter.default.post(name: .entrySearchGoogle, object: entry)
    }
    
    func handleWikipedia() {
        isShowingActions = false
        NotificationCenter.default.post(name: .entrySearchWikipedia, object: entry)
    }
}
