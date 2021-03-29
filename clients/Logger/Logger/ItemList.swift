import SwiftUI
import PartialSheet

struct ItemList: View {
    let items: [Item]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 2) {
                ForEach(items) { item in
                    ItemRow(item: item)
                        .flipUpsideDown()
                }
            }
            .padding(.horizontal, 16)
        }
        .flipUpsideDown()
    }
}

struct ItemRow: View {
    @EnvironmentObject var sheetManager: PartialSheetManager
    
    let item: Item
     
    @State var confirmDelete = false
    
    var body: some View {
        Text(item.text)
            .padding(EdgeInsets(top: 11, leading: 18, bottom: 11, trailing: 18))
            .background(Color(itemBackground: item.color))
            .foregroundColor(Color(itemForeground: item.color))
            .cornerRadius(22)
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .onTapGesture {
                sheetManager.showPartialSheet({}) {
                    ItemMenu(text: item.text, actions: [
                        .divider,
                        .tags(tags: item.tags, action: handleTag),
                        .colorPicker(color: item.color, action: handleColor),
                        .action(title: "Google", icon: "magnifyingglass", action: handleGoogle),
                        .action(title: "Wikipedia", icon: "book", action: handleWikipedia),
                        .destructive(title: "Delete", icon: "trash", action: handleConfirmDelete),
                    ])
                    .frame(height: 400)
                }
            }
            .alert(isPresented: $confirmDelete) {
                Alert(title: Text("Are you sure?"),
                      primaryButton: .destructive(Text("Delete"), action: handleDelete),
                      secondaryButton: .cancel())
            }
    }
    
    func handleConfirmDelete() {
        confirmDelete = true
    }
    
    func handleDelete() {
        sheetManager.closePartialSheet()
        NotificationCenter.default.post(name: .itemDelete, object: item)
    }
    
    func handleGoogle() {
        sheetManager.closePartialSheet()
        NotificationCenter.default.post(name: .itemSearchGoogle, object: item)
    }
    
    func handleWikipedia() {
        sheetManager.closePartialSheet()
        NotificationCenter.default.post(name: .itemSearchWikipedia, object: item)
    }
    
    func handleColor(_ color: Int64) {
        let updated = Item(id: item.id, text: item.text, color: color, tags: [])
        NotificationCenter.default.post(name: .itemSave, object: updated)
    }
    
    func handleTag(_ tag: Tag) {
        guard let url = URL(string: "logger:tag=\(tag.id)") else { return }
        UIApplication.shared.open(url)
    }
}
