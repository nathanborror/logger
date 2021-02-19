import Foundation
import SwiftUI

// MARK: - Notifications

extension Notification.Name {
    static let entryDelete = Notification.Name("EntryDeleteNotification")
    static let entrySearchGoogle = Notification.Name("EntrySearchGoogleNotification")
    static let entrySearchWikipedia = Notification.Name("EntrySearchWikipediaNotification")
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
