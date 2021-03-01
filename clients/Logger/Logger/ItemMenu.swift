import SwiftUI
import LoggerKit

struct ItemMenu: View {
    
    let text: String
    let color: Int64
    let colorChange: (Int64) -> Void
    let actions: [ItemAction]
    
    var body: some View {
        VStack {
            Text(text)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.systemGray)
                .padding()
            VStack(alignment: .leading, spacing: 4) {
                ForEach(actions) {
                    ItemMenuAction(action: $0)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ItemColorSwatch(color: "#00CDFF", selected: color == 2, action: { colorChange(2) })
                    ItemColorSwatch(color: "#00DF95", selected: color == 3, action: { colorChange(3) })
                    ItemColorSwatch(color: "#DF008E", selected: color == 4, action: { colorChange(4) })
                    ItemColorSwatch(color: "#FF8B00", selected: color == 5, action: { colorChange(5) })
                    ItemColorSwatch(color: "#E3E3E3", selected: color == 0, action: { colorChange(0) })
                    ItemColorSwatch(color: "#000000", selected: color == 1, action: { colorChange(1) })
                }
                .padding(.horizontal)
                .padding(.vertical, 2)
            }
            
            Spacer()
        }
    }
}

enum ItemAction: Identifiable {
    var id: UUID { UUID() }
    
    case action(title: String, icon: String, action: () -> Void)
    case destructive(title: String, icon: String, action: () -> Void)
}

struct ItemMenuAction: View {
    let action: ItemAction
    
    var body: some View {
        switch action {
        case let .action(title, icon, action):
            render(title: title, icon: icon, action: action)
                .foregroundColor(.label)
        case let .destructive(title, icon, action):
            render(title: title, icon: icon, action: action)
                .foregroundColor(.systemPink)
        }
    }
    
    func render(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Image(systemName: icon)
                    .frame(width: 44, height: 44)
                Text(title)
                Spacer()
            }
        }
        .background(Color(hex: 0xF4F4F5))
        .cornerRadius(6)
    }
}

struct ItemColorSwatch: View {
    let color: String
    let selected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: selected ? "smallcircle.fill.circle.fill" : "circle.fill")
        }
        .foregroundColor(Color(hex: color))
        .font(.system(size: 44))
        .padding(.vertical, 16)
    }
}
