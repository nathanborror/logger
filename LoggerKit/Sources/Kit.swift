import Foundation

public class Kit {

    public static let StateDidChange = Notification.Name("KitStateDidChange")

    public static var images: Images { return shared.images }
    public static var state: State { return shared.state }

    internal static var shared: Kit = Kit()
    internal static var store: Store { return shared.store }

    internal var state: State
    internal var store: Store
    internal var images: Images

    internal var downloads: DispatchQueue
    internal var commits: DispatchQueue

    init() {
        self.state = State()
        self.store = try! Store()
        self.images = Images()
        self.downloads = DispatchQueue(label: "downloads.queue")
        self.commits = DispatchQueue(label: "commits.queue")
    }

    public static func observe(_ observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: Kit.StateDidChange, object: nil)
        notify()
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
