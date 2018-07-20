import UIKit
import LoggerKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .background
        window?.rootViewController = EntriesVC()
        window?.makeKeyAndVisible()

        #if targetEnvironment(simulator)
        Kit.subscribe(self, selector: #selector(stateChange))
        #endif

        return true
    }

    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // TODO: Ask people before replacing the database!
        // TODO: Test bogus files
        // TODO: Store old databases someplace safe where they can be resurrected

        do {
            try Kit.replaceDatabase(with: url)
        } catch {
            print("Error AppDelegate.open:", error)
        }
        return true
    }

    #if targetEnvironment(simulator)
    @objc func stateChange(notification: Notification) {
        guard let action = notification.userInfo?["action"] as? String else { return }
        guard let state = notification.userInfo?["state"] as? State else { return }
        try! debugger.write(action: action, state: state, snapshot: window!)
    }

    private let debugger = Debugger()
    #endif
}
