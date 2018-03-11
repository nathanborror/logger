/// This is a generated file, do not edit

import Foundation

extension Date {

    public static var since1970: Int {
        return Int(Date().timeIntervalSince1970)
    }

    public var naturalDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true

        if Calendar.autoupdatingCurrent.isDateInToday(self) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            return "\(formatter.string(from: self)), \(timeFormatter.string(from: self))"
        }

        return formatter.string(from: self)
    }

    public var naturalDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: self)
    }

    public func truncate(to components: Set<Calendar.Component>) -> Date {
        let comp: DateComponents = Calendar.current.dateComponents(components, from: self)
        return Calendar.current.date(from: comp) ?? self
    }
}
