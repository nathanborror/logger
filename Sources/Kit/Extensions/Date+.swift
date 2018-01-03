/// This is a generated file, do not edit

import Foundation

extension Date {

    public static let rfc3339: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z"
        return formatter
    }()

    public var rfc3339: String {
        return Date.rfc3339.string(from: self)
    }

    public init?(rfc3339String str: String?) {
        guard let str = str else {
            return nil
        }
        guard let date = Date.rfc3339.date(from: str) else {
            return nil
        }
        self.init(timeInterval: 0, since: date)
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
