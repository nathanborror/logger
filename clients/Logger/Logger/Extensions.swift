import Foundation
import SwiftUI
import LoggerKit
import CoreLocation
import Combine

// MARK: - Notifications

extension Notification.Name {
    static let itemSave = Notification.Name("ItemSaveNotification")
    static let itemDelete = Notification.Name("ItemDeleteNotification")
    static let itemSearch = Notification.Name("ItemSearchNotification")
    static let itemSearchGoogle = Notification.Name("ItemSearchGoogleNotification")
    static let itemSearchWikipedia = Notification.Name("ItemSearchWikipediaNotification")
}

// MARK: - File Manager

extension FileManager {
    
    public static func document(named filename: String) -> URL {
        return url(for: .documentDirectory).appendingPathComponent(filename)
    }

    public static func url(for path: FileManager.SearchPathDirectory, folder: String? = nil) -> URL {
        var dir = try! FileManager.default.url(for: path, in: .userDomainMask, appropriateFor: nil, create: true)
        if let folder = folder {
            dir.appendPathComponent(folder, isDirectory: true)
            if FileManager.default.fileExists(atPath: dir.path) == false {
                try! FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            }
        }
        return dir
    }
    
    public static func move(from: URL, to: URL) {
        do { try FileManager.default.moveItem(at: from, to: to) }
        catch { print(error) }
    }
    
    public static func replace(at destination: URL, with new: URL) {
        FileManager.delete(destination)
        FileManager.move(from: new, to: destination)
    }
    
    public static func delete(_ url: URL) {
        do { try FileManager.default.removeItem(at: url) }
        catch { print(error) }
    }
}

// MARK: - View Modifiers

struct FlippedUpsideDown: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

extension View {
    func flipUpsideDown() -> some View {
        self.modifier(FlippedUpsideDown())
    }
}

// MARK: - String

extension String {

    func removePrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

// MARK: - Color

typealias HexString = String

extension Color {
    
    static let label = Color(.label)
    static let secondaryLabel = Color(.secondaryLabel)
    static let systemBackground = Color(.systemBackground)
    
    static let systemPink = Color(.systemPink)
    static let systemOrange = Color(.systemOrange)
    static let systemTeal = Color(.systemTeal)
    static let systemGreen = Color(.systemGreen)
    static let systemGray = Color(.systemGray)
    static let systemFill = Color(.systemFill)
        
    init(hex: HexString, opacity: Double = 1) {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if str.hasPrefix("#") {
            str.remove(at: str.startIndex)
        }
        if str.count == 3 {
            str = str + str
        }
        if str.count != 6 {
            self = .gray
        }
        var value: UInt64 = 0
        Scanner(string: str).scanHexInt64(&value)
        self.init(hex: value, opacity: opacity)
    }
    
    init(hex: UInt64, opacity: Double = 1) {
        let convert: (Int) -> Double = { val in
            return Double((hex >> val) & 0xff) / 255
        }
        let (r,g,b) = (convert(16), convert(08), convert(00))
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
    
    init(itemBackground id: Int64) {
        switch id {
        case 1:
            self = .init(hex: "#000000")
        case 2:
            self = .init(hex: "#00CDFF")
        case 3:
            self = .init(hex: "#00DF95")
        case 4:
            self = .init(hex: "#DF008E")
        case 5:
            self = .init(hex: "#FF8B00")
        default:
            self = .init(hex: "#E3E3E3")
        }
    }
    
    init(itemForeground id: Int64) {
        switch id {
        case 1...5:
            self = .init(hex: "#FFFFFF")
        default:
            self = .init(hex: "#000000")
        }
    }
    
    var hex: HexString {
        guard let c = cgColor?.components else {
            return "#000000"
        }
        let convert: (CGFloat) -> Int = { val in
            lroundf(Float(val * 255))
        }
        let (r,g,b) = (convert(c[0]), convert(c[1]), convert(c[2]))
        return String(format: "#%02lX%02lX%02lX", r, g, b)
    }
}

// MARK: - JSON

extension JSONDecoder.DateDecodingStrategy {

    public static let customISO8601 = custom {
        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)
        if let date = Formatter.iso8601.date(from: string) ?? Formatter.iso8601noFS.date(from: string) {
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
    }
}

extension JSONEncoder.DateEncodingStrategy {

    public static let customISO8601 = custom {
        var container = $1.singleValueContainer()
        try container.encode(Formatter.iso8601.string(from: $0))
    }
}

extension Formatter {

    public static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    public static let iso8601noFS = ISO8601DateFormatter()
}

// MARK: - CoreLocation

extension CLLocationManager {
    
    static func publishLocation() -> LocationPublisher {
        return .init()
    }
    
    struct LocationPublisher: Publisher {
        typealias Output = CLLocation
        typealias Failure = Never
        
        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = LocationSubscription(subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
        
        final class LocationSubscription<S: Subscriber>: NSObject, CLLocationManagerDelegate, Subscription where S.Input == Output, S.Failure == Failure {
            var subscriber: S
            var locationManager = CLLocationManager()
            
            init(subscriber: S) {
                self.subscriber = subscriber
                super.init()
                locationManager.delegate = self
            }
            
            func request(_ demand: Subscribers.Demand) {
                locationManager.startUpdatingLocation()
                locationManager.requestWhenInUseAuthorization()
            }
            
            func cancel() {
                locationManager.stopUpdatingLocation()
            }
            
            func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                for location in locations {
                    _ = subscriber.receive(location)
                }
            }
        }
    }
}

extension CLLocation {
    func placemark(completion: @escaping (CLPlacemark?, Error?) -> Void) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
    }
}
