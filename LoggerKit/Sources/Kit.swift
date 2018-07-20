import Foundation

extension FileManager {

    public static var database: URL {
        return url(for: .documentDirectory).appendingPathComponent("data.logger")
    }

    public static var photosDir: URL {
        return url(for: .documentDirectory, folder: "Photos")
    }

    public static var photosCacheDir: URL {
        return url(for: .cachesDirectory, folder: "Photos")
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

public class Kit {

    public static let StateDidChange = Notification.Name("KitStateDidChange")

    public static var state: State { return shared.state }

    static var shared: Kit = Kit()
    static var store: Store { return shared.store }

    internal var state: State
    internal var store: Store!

    internal var downloads: DispatchQueue
    internal var commits: DispatchQueue

    init() {
        self.state = State()
        self.store = try! Store(url: FileManager.database)
        self.downloads = DispatchQueue(label: "downloads.queue")
        self.commits = DispatchQueue(label: "commits.queue")

        NotificationCenter.default.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) { _ in
            try! Kit.activate()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public static func subscribe(_ observer: NSObject, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: Kit.StateDidChange, object: nil)

        // Call selector with current state
        let userInfo: [String: Any] = ["action": "init", "state": shared.state]
        let notification = Notification(name: Kit.StateDidChange, object: nil, userInfo: userInfo)
        observer.perform(selector, with: notification)
    }

    public static func unsubscribe(_ observer: NSObject) {
        NotificationCenter.default.removeObserver(observer, name: Kit.StateDidChange, object: nil)
    }

    public static func replaceDatabase(with url: URL) throws {
        let data = try Data(contentsOf: url)
        FileManager.default.createFile(atPath: FileManager.database.path, contents: data)
        shared.store = try Store(url: FileManager.database)
        try Kit.activate()
    }

    internal static func commit(_ action: String, mutation: @escaping (inout State) -> Void) {
        shared.commits.async {
            var state = shared.state
            mutation(&state)
            if state != shared.state {
                shared.state = state
                DispatchQueue.main.async { notify(action, state: state) }
            }
        }
    }

    internal static func notify(_ action: String, state: State) {
        assert(Thread.isMainThread)
        let userInfo: [String: Any] = ["action": action, "state": state]
        NotificationCenter.default.post(name: StateDidChange, object: nil, userInfo: userInfo)
    }
}
