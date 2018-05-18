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
        return true
    }

    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // TODO: Ask people before replacing the database!
        // TODO: Test bogus files
        // TODO: Store old databases someplace safe where they can be resurrected

        try! Kit.replaceDatabase(with: url)
        return true
    }
}
