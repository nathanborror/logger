/// Internets broadcasts changes in the availability of the network as it comes
/// as goes, as you drive through tunnels open your laptop in a new coffee shop,
/// or run out of battery on your hotspot.

import Foundation
import SystemConfiguration

public class Internets {

    public static let StatusDidChange = Notification.Name("InternetsStatusDidChange")

    public enum Status {
        case online
        case offline
    }

    private let reachability: SCNetworkReachability
    private var flags: SCNetworkReachabilityFlags

    init() {
        self.reachability = Internets.reachabilityWithZeroAddress()
        self.flags = SCNetworkReachabilityFlags()
        startListening()
    }

    deinit {
        stopListening()
    }

    private static func reachabilityWithZeroAddress() -> SCNetworkReachability {
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        return withUnsafePointer(to: &address, { pointer in
            return pointer.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) {
                return SCNetworkReachabilityCreateWithAddress(nil, $0)!
            }
        })
    }

    private func startListening() {
        var context = SCNetworkReachabilityContext(
            version: 0, info: nil,
            retain: nil, release: nil,
            copyDescription: nil)

        // Callback context gets a weak reference to self
        context.info = Unmanaged.passUnretained(self).toOpaque()

        // Install Callback
        SCNetworkReachabilitySetCallback(reachability, { (_, flags, info) in
            let internets = Unmanaged<Internets>.fromOpaque(info!).takeUnretainedValue()
            internets.updateSubscribers(flags: flags)
        }, &context)
        guard SCNetworkReachabilitySetDispatchQueue(reachability, DispatchQueue.main) else {
            print("SCNetworkReachabilitySetDispatchQueue failed"); return
        }
    }

    private func stopListening() {
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
    }

    private func updateSubscribers(flags updatedFlags: SCNetworkReachabilityFlags) {
        flags = updatedFlags
        let userInfo = ["status": Status(flags: updatedFlags)]
        NotificationCenter.default.post(name: Internets.StatusDidChange, object: nil, userInfo: userInfo)
    }
}

private extension Internets.Status {

    init(flags: SCNetworkReachabilityFlags) {
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        let isOnline = isReachable && (!needsConnection || canConnectWithoutUserInteraction)
        self = isOnline ? .online : .offline
    }
}
