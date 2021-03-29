import SwiftUI

struct ComposerExpandedView: View {
    @State var text: String = ""
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top) {
                Menu {
                    Button(action: {}) { Text("New Group") }
                    Button(action: {}) { Text("Settings") }
                } label: {
                    TokenButton(name: "slider.horizontal.3")
                }
                
                TextField("Log something...", text: $text)
                    .padding(EdgeInsets(top: 9, leading: 20, bottom: 9, trailing: 64))
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(1)
                    .background(Color(hue: 240/360, saturation: 1/100, brightness: 78/100))
                    .cornerRadius(20)
                
                Button(action: { print("not implemented") }) {
                    Token(icon: "book", name: "book")
                }.contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                
                Button(action: { print("not implemented") }) {
                    Token(icon: "location", name: "location")
                }.contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                
                Button(action: { print("not implemented") }) {
                    Token(icon: "video", name: "movie")
                }.contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
    }
}

var tokenForeground = Color(.displayP3, white: 0.4)
var tokenBackground = Color(.displayP3, white: 0.9)

struct Token: View {
    let icon: String
    let name: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(name)
        }
        .foregroundColor(tokenForeground)
        .padding(.horizontal, 20)
        .padding(.vertical, 11)
        .background(Color(.displayP3, white: 0.9))
        .cornerRadius(20)
    }
}

struct TokenButton: View {
    let name: String
    
    var body: some View {
        Image(systemName: name)
            .foregroundColor(tokenForeground)
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .background(Color(.displayP3, white: 0.9))
            .cornerRadius(20)
    }
}

// MARK: - Preview

struct ComposerExpandedView_Previews: PreviewProvider {
    static var previews: some View {
        ComposerExpandedView()
            .previewLayout(.fixed(width: 375, height: 88))
    }
}
