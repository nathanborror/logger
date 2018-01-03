/// This is a generated file, do not edit

import Foundation
import SystemConfiguration

/// The `NetworkReachabilityManager` class listens for reachability changes of hosts and addresses for both WWAN and
/// WiFi network interfaces.
///
/// Reachability can be used to determine background information about why a network operation failed, or to retry
/// network requests when a connection is established. It should not be used to prevent a user from initiating a network
/// request, as it's possible that an initial request may be required to establish reachability.
public class NetworkReachabilityManager {
    /// Defines the various states of network reachability.
    ///
    /// - unknown:      It is unknown whether the network is reachable.
    /// - notReachable: The network is not reachable.
    /// - reachable:    The network is reachable.
    public enum NetworkReachabilityStatus {
        case unknown
        case notReachable
        case reachable(ConnectionType)
    }

    /// Defines the various connection types detected by reachability flags.
    ///
    /// - ethernetOrWiFi: The connection type is either over Ethernet or WiFi.
    /// - wwan:           The connection type is a WWAN connection.
    public enum ConnectionType {
        case ethernetOrWiFi
        case wwan
    }

    /// A closure executed when the network reachability status changes. The closure takes a single argument: the
    /// network reachability status.
    public typealias Listener = (NetworkReachabilityStatus) -> Void

    // MARK: - Properties

    /// Whether the network is currently reachable.
    public var isReachable: Bool { return isReachableOnWWAN || isReachableOnEthernetOrWiFi }

    /// Whether the network is currently reachable over the WWAN interface.
    public var isReachableOnWWAN: Bool { return networkReachabilityStatus == .reachable(.wwan) }

    /// Whether the network is currently reachable over Ethernet or WiFi interface.
    public var isReachableOnEthernetOrWiFi: Bool { return networkReachabilityStatus == .reachable(.ethernetOrWiFi) }

    /// The current network reachability status.
    public var networkReachabilityStatus: NetworkReachabilityStatus {
        guard let flags = self.flags else { return .unknown }
        return networkReachabilityStatusForFlags(flags)
    }

    /// The dispatch queue to execute the `listener` closure on.
    public var listenerQueue: DispatchQueue = DispatchQueue.main

    /// A closure executed when the network reachability status changes.
    public var listener: Listener?

    private var flags: SCNetworkReachabilityFlags? {
        var flags = SCNetworkReachabilityFlags()

        if SCNetworkReachabilityGetFlags(reachability, &flags) {
            return flags
        }

        return nil
    }

    private let reachability: SCNetworkReachability
    private var previousFlags: SCNetworkReachabilityFlags

    // MARK: - Initialization

    /// Creates a `NetworkReachabilityManager` instance with the specified host.
    ///
    /// - Parameter host: The host used to evaluate network reachability.
    /// - Returns: The new `NetworkReachabilityManager` instance.
    public convenience init?(host: String) {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else { return nil }
        self.init(reachability: reachability)
    }

    /// Creates a `NetworkReachabilityManager` instance that monitors the address 0.0.0.0.
    ///
    /// Reachability treats the 0.0.0.0 address as a special token that causes it to monitor the general routing
    /// status of the device, both IPv4 and IPv6.
    ///
    /// - Returns: The new `NetworkReachabilityManager` instance.
    public convenience init?() {
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)

        guard let reachability = withUnsafePointer(to: &address, { pointer in
            return pointer.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) {
                return SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else { return nil }

        self.init(reachability: reachability)
    }

    private init(reachability: SCNetworkReachability) {
        self.reachability = reachability
        self.previousFlags = SCNetworkReachabilityFlags()
    }

    deinit {
        stopListening()
    }

    // MARK: - Listening

    /// Starts listening for changes in network reachability status.
    ///
    /// - Returns: `true` if listening was started successfully, `false` otherwise.
    @discardableResult
    public func startListening() -> Bool {
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = Unmanaged.passUnretained(self).toOpaque()

        let callbackEnabled = SCNetworkReachabilitySetCallback(
            reachability,
            { (_, flags, info) in
                let reachability = Unmanaged<NetworkReachabilityManager>.fromOpaque(info!).takeUnretainedValue()
                reachability.notifyListener(flags)
        },
            &context
        )

        let queueEnabled = SCNetworkReachabilitySetDispatchQueue(reachability, listenerQueue)

        listenerQueue.async {
            self.previousFlags = SCNetworkReachabilityFlags()
            self.notifyListener(self.flags ?? SCNetworkReachabilityFlags())
        }

        return callbackEnabled && queueEnabled
    }

    /// Stops listening for changes in network reachability status.
    public func stopListening() {
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
    }

    // MARK: - Internal - Listener Notification

    func notifyListener(_ flags: SCNetworkReachabilityFlags) {
        guard previousFlags != flags else { return }
        previousFlags = flags

        listener?(networkReachabilityStatusForFlags(flags))
    }

    // MARK: - Internal - Network Reachability Status

    func networkReachabilityStatusForFlags(_ flags: SCNetworkReachabilityFlags) -> NetworkReachabilityStatus {
        guard isNetworkReachable(with: flags) else { return .notReachable }

        var networkStatus: NetworkReachabilityStatus = .reachable(.ethernetOrWiFi)

        #if os(iOS)
            if flags.contains(.isWWAN) { networkStatus = .reachable(.wwan) }
        #endif

        return networkStatus
    }

    func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)

        return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
    }
}

extension NetworkReachabilityManager.NetworkReachabilityStatus: Equatable {}

/// Returns whether the two network reachability status values are equal.
///
/// - Parameter lhs: The left-hand side value to compare.
/// - Parameter rhs: The right-hand side value to compare.
///
/// - Returns: `true` if the two values are equal, `false` otherwise.
public func ==(
    lhs: NetworkReachabilityManager.NetworkReachabilityStatus,
    rhs: NetworkReachabilityManager.NetworkReachabilityStatus)
    -> Bool
{
    switch (lhs, rhs) {
    case (.unknown, .unknown):
        return true
    case (.notReachable, .notReachable):
        return true
    case let (.reachable(lhsConnectionType), .reachable(rhsConnectionType)):
        return lhsConnectionType == rhsConnectionType
    default:
        return false
    }
}


