import Foundation

class Messages {

    private var inbox: [Message]
    private var archive: [Message]
    private var subs: Subscription<Messages>

    init() {
        self.inbox = []
        self.archive = []
        self.subs = Subscription<Messages>()
    }

    func subscribe<T: AnyObject>(_ target: T, action: @escaping (T) -> (Messages) -> Void) {
        subs.subscribe(target, action: action)
    }

    func insert(message: Message) {
        inbox.append(message)
        subs.broadcast(self)
    }

    func read() -> [Message] {
        let out = self.inbox
        self.inbox = []
        self.archive += out
        return out
    }
}

public struct Message {
    public var message: String
    public var level: Level
    public var target: UUID?
    public var error: KitError?

    public enum Level: Int {
        case debug   = 100
        case info    = 200
        case success = 250
        case warning = 300
        case error   = 400
    }
}

extension Message {

    init(debug message: String, target: UUID? = nil) {
        self.message = message
        self.level = .debug
        self.target = target
        self.error = nil
    }

    init(info message: String, target: UUID? = nil) {
        self.message = message
        self.level = .info
        self.target = target
        self.error = nil
    }

    init(success message: String, target: UUID? = nil) {
        self.message = message
        self.level = .success
        self.target = target
        self.error = nil
    }

    init(warning message: String, target: UUID? = nil) {
        self.message = message
        self.level = .warning
        self.target = target
        self.error = nil
    }

    init(error: KitError, target: UUID? = nil) {
        self.error = error
        self.message = self.error?.localizedDescription ?? "Unknown"
        self.level = .error
        self.target = target
    }
}
