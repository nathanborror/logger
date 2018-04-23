import Foundation

var defaultDatabaseURL: URL {
    let dir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    return dir.appendingPathComponent("data.logger")
}

var defaultPhotosURL: URL {
    var dir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    dir.appendPathComponent("Photos", isDirectory: true)
    if FileManager.default.fileExists(atPath: dir.path) == false {
        try! FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }
    return dir
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
        self.store = try! Store(url: defaultDatabaseURL)
        self.downloads = DispatchQueue(label: "downloads.queue")
        self.commits = DispatchQueue(label: "commits.queue")

        NotificationCenter.default.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) { _ in
            try! Kit.activate()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public static func observe(_ observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: Kit.StateDidChange, object: nil)
        notify()
    }

    public static func replaceDatabase(with url: URL) throws {
        let data = try Data(contentsOf: url)
        FileManager.default.createFile(atPath: defaultDatabaseURL.path, contents: data)
        shared.store = try Store(url: defaultDatabaseURL)
        try Kit.activate()
    }

    internal static func commit(_ mutation: @escaping (inout State) -> Void) {
        shared.commits.async {
            var state = shared.state
            mutation(&state)
            shared.state = state
            DispatchQueue.main.async { notify() }
        }
    }

    internal static func notify() {
        assert(Thread.isMainThread)
        NotificationCenter.default.post(name: StateDidChange, object: nil, userInfo: nil)
    }
}
