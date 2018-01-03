import UIKit

extension State {

    init() {
        self.markers = [:]
        self.error = nil
    }

    mutating func apply(marker: Marker) {
        if var existing = markers[marker.id] {
            existing.apply(text: marker.text, color: marker.color)
            self.markers[existing.id] = existing
        } else {
            self.markers[marker.id] = marker
        }
    }

    mutating func apply(error: KitError) {
        print("Service Error: \(error)")
        self.error = error
    }
}

extension Marker {

    init(_ text: String, color: Int?) {
        self.id = UUID()
        self.text = text
        self.color = color ?? 0x000000
        self.created = Date()
        self.modified = Date()
        self.error = nil
    }

    mutating func apply(text: String, color: Int) {
        self.text = text
        self.color = color
        self.modified = Date()
    }
}
