import SwiftUI
import CoreLocation

struct ComposerView: View {
    
    @State var text = ""
    @State var isSearching = false
    @State var isEmpty = true
    @State var locator = CLLocationManager.publishLocation()
    @State var tagGeoCoords: String? = nil
    @State var tagWeather: String? = nil
    
    var body: some View {
        HStack {
            if isSearching {
                Image(systemName: "magnifyingglass")
                    .font(Font.system(size: 18))
                    .padding(.leading, 11)
                    .foregroundColor(.gray)
            }
            TextField("Remember something...", text: $text)
                .padding(EdgeInsets(top: 9, leading: isSearching ? 0 : 20, bottom: 9, trailing: 20))
                .onChange(of: text) { (value) in
                    isSearching = value.hasPrefix(" ")
                    isEmpty = value.trimmingCharacters(in: .whitespacesAndNewlines) == ""
                    if isSearching { handleSearch() }
                }
            if isSearching {
                Button(action: handleClear) {
                    Image(systemName: "xmark.circle.fill")
                        .font(Font.system(size: 22))
                        .padding(.trailing, 9)
                        .foregroundColor(.gray)
                }
            }
            if !isEmpty && !isSearching {
                Button(action: handleSubmit) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(Font.system(size: 31))
                        .padding(.trailing, 3)
                }
            }
            
        }
        .background(Color.white)
        .cornerRadius(20)
        .padding(1)
        .background(Color(hue: 240/360, saturation: 1/100, brightness: 78/100))
        .cornerRadius(22)
        .onReceive(locator) { location in
            tagGeoCoords = String(format: "#geo:coords=%f,%f", location.coordinate.latitude, location.coordinate.longitude)
            GetWeather(coords: location.coordinate) { (weather) in
                tagWeather = String(format: "#weather=%@", weather.weather.first?.main.lowercased() ?? "")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .itemSearch), perform: handleSearchNotification)
    }
    
    func handleSubmit() {
        guard text != "" else { return }
        let item = Item(id: 0, text: [text, tagGeoCoords, tagWeather].compactMap({$0}).joined(separator: " "), color: 0, tags: [])
        NotificationCenter.default.post(name: .itemSave, object: item)
        text = ""
    }
    
    func handleClear() {
        text = ""
        isSearching = false
        isEmpty = true
        handleSearch()
    }
    
    func handleSearch() {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        NotificationCenter.default.post(name: .itemSearch, object: query)
    }
    
    func handleSearchNotification(_ publisher: NotificationCenter.Publisher.Output) {
        guard let query = publisher.object as? String else { return }
        guard query != "" else { return }
        text = " \(query)"
        isSearching = true
        isEmpty = false
    }
}

// MARK: - Preview

struct ComposerView_Previews: PreviewProvider {
    static var previews: some View {
        ComposerView()
            .padding()
            .previewLayout(.fixed(width: 375, height: 88))
        
        ComposerView(text: " ", isSearching: true, isEmpty: true)
            .padding()
            .previewLayout(.fixed(width: 375, height: 88))
        
        ComposerView(text: "Test", isSearching: false, isEmpty: false)
            .padding()
            .previewLayout(.fixed(width: 375, height: 88))
    }
}
