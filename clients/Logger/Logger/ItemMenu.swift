import SwiftUI
import LoggerKit

struct ItemMenu: View {
    let text: String
    let actions: [ItemAction]
    
    var body: some View {
        VStack {
            Text(text)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.systemGray)
                .padding(.horizontal)
            VStack(alignment: .leading, spacing: 4) {
                ForEach(actions) {
                    ItemMenuAction(action: $0)
                }
            }
            Spacer()
        }
    }
}

enum ItemAction: Identifiable {
    var id: UUID { UUID() }
    
    case action(title: String, icon: String, action: () -> Void)
    case destructive(title: String, icon: String, action: () -> Void)
    case colorPicker(color: Int64, action: (Int64) -> Void)
    case tags(tags: [Tag], action: (Tag) -> Void)
    case divider
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
        case let .colorPicker(color, action):
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 11) {
                    ItemColorSwatch(color: "#00CDFF", selected: color == 2, action: { action(2) })
                    ItemColorSwatch(color: "#00DF95", selected: color == 3, action: { action(3) })
                    ItemColorSwatch(color: "#DF008E", selected: color == 4, action: { action(4) })
                    ItemColorSwatch(color: "#FF8B00", selected: color == 5, action: { action(5) })
                    ItemColorSwatch(color: "#E3E3E3", selected: color == 0, action: { action(0) })
                    ItemColorSwatch(color: "#000000", selected: color == 1, action: { action(1) })
                }.padding(.horizontal)
            }
            Divider()
        case let .tags(tags, action):
            if tags.count > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 11) {
                        ForEach(tags) { tag in
                            ItemTag(tag: tag, action: { action(tag) })
                        }
                    }.padding(.horizontal)
                }
                Divider()
            }
        case .divider:
            Divider()
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
        .padding(.horizontal)
    }
}

struct Divider: View {
    
    var body: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(Color(hex: 0xF4F4F5))
            .padding(.vertical, 16)
            .padding(.horizontal)
    }
}

struct ItemColorSwatch: View {
    let color: String
    let selected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if selected {
                    Image(systemName: "checkmark")
                }
            }
            .frame(width: 48, height: 48)
            .foregroundColor(Color.white)
            .background(Color(hex: color))
            .cornerRadius(6)
        }
    }
}

struct ItemTag: View {
    let tag: Tag
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Group {
                if tag.key == "weather" {
                    Image(systemName: weatherIcon(tag.value))
                } else {
                    Text(tag.value)
                }
            }
            .padding(12)
            .foregroundColor(Color.black)
            .background(Color(hex: 0xF4F4F5))
            .cornerRadius(6)
        }
    }
}

func weatherIcon(_ name: String) -> String {
    switch name {
    case "thunderstorm":    return "cloud.bolt"
    case "drizzle":         return "cloud.drizzle"
    case "rain":            return "cloud.heavyrain"
    case "snow":            return "snow"
    case "clear":           return "sun.max"
    case "clouds":          return "cloud"
    case "mist":            return ""
    case "smoke":           return "smoke"
    case "dust":            return ""
    case "fog", "haze":     return "cloud.fog"
    case "sand":            return ""
    case "ash":             return "aqi.high"
    case "squall":          return ""
    case "tornado":         return "tornado"
    default:                return "sun.max"
    }
}

// MARK: - Preview

struct ItemMenu_Previews: PreviewProvider {
    static var previews: some View {
        ItemMenu(text: "This is my favorite note", actions: [
            .divider,
            .tags(tags: [
                    Tag(id: "weather=sunny", namespace: "", key: "weather", value: "sunny"),
                    Tag(id: "location=44.2916979,-121.5511398", namespace: "", key:"location", value: "44.2916979,-121.5511398"),
                    Tag(id: "book", namespace: "", key: "", value: "book")], action: {_ in}),
            .colorPicker(color: 3, action: {_ in}),
            .action(title: "Google", icon: "magnifyingglass", action: {}),
            .action(title: "Wikipedia", icon: "book", action: {}),
            .destructive(title: "Delete", icon: "trash", action: {}),
        ])
        .previewLayout(.fixed(width: 375, height: 480))
    }
}
