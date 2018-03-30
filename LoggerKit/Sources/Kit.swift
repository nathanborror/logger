import Foundation

public class Kit {

    public static let StateDidChange = Notification.Name("KitStateDidChange")

    public static var images: Images { return shared.images }
    public static var state: State { return shared.state }

    static var shared: Kit = Kit()
    static var store: Store { return shared.store }

    internal var state: State
    internal var store: Store!
    internal var images: Images

    internal var downloads: DispatchQueue
    internal var commits: DispatchQueue

    init() {
        self.state = State()
        self.images = Images()
        self.downloads = DispatchQueue(label: "downloads.queue")
        self.commits = DispatchQueue(label: "commits.queue")

        guard FileManager.default.ubiquityIdentityToken != nil else {
            self.state.isCloudEnabled = false
            return
        }
        self.store = try! Store(delegate: self)
    }

    public static func observe(_ observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: Kit.StateDidChange, object: nil)
        notify()
    }

    public static func retryCloud() {
        guard FileManager.default.ubiquityIdentityToken != nil else {
            commit { $0.isCloudEnabled = false }
            return
        }
        shared.store = try! Store(delegate: shared)
        commit { $0.isCloudEnabled = true }
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

extension Kit: StoreDelegate {

    func store(_ store: Store, didChangeStage stage: Store.Stage) {
        guard stage == .ready else { return }
        do    { try Kit.activate() }
        catch { print(error) }
    }
}
