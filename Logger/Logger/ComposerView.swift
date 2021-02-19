import SwiftUI

struct ComposerView: View {
    
    var onSubmit: (String) -> Void
    
    @State var text = ""
    @State var isSearching = false
    @State var isEmpty = true
    
    var body: some View {
        ZStack(alignment: isSearching ? .topLeading : .topTrailing) {
            TextField("Remember something...", text: $text)
                .padding(EdgeInsets(top: 9, leading: isSearching ? 32 : 20, bottom: 9, trailing: 20))
                .background(Color.white)
                .cornerRadius(20)
                .padding(1)
                .background(Color(hue: 240/360, saturation: 1/100, brightness: 78/100))
                .cornerRadius(20)
                .onChange(of: text) { (value) in
                    isSearching = value.hasPrefix(" ")
                    isEmpty = value == ""
                }
            if isSearching {
                Image(systemName: "magnifyingglass")
                    .font(Font.system(size: 18))
                    .padding(EdgeInsets(top: 11, leading: 12, bottom: 0, trailing: 0))
                    .foregroundColor(.gray)
            } else if !isEmpty {
                Button(action: handleSubmit) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(Font.system(size: 31))
                        .padding(EdgeInsets(top: 3, leading: 0, bottom: 0, trailing: 3))
                }
            }
        }
    }
    
    func handleSubmit() {
        guard text != "" else { return }
        onSubmit(text)
        text = ""
    }
}
