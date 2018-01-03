/// This is a generated file, do not edit

import Foundation

public struct Subscription<V> {

    private var subs = [Subscriber]()

    internal mutating func broadcast(_ value: V) {
        subs = subs.filter {
            let targetStillThere = $0.broadcast(value)
            return targetStillThere
        }
    }

    public mutating func subscribe<T: AnyObject>(_ target: T, action: @escaping (T) -> (V) -> ()) {
        guard !subs.contains(where: { $0.hasTarget(target)}) else {
            return
        }
        subs.append(SubscriptionWithTarget(target: target, action: action))
    }

    public mutating func unsubscribe(_ target: AnyObject) {
        subs = subs.filter { !$0.hasTarget(target) }
    }
}

protocol Subscriber {

    func broadcast(_ value: Any?) -> Bool
    func hasTarget(_ target: AnyObject) -> Bool
}

private struct SubscriptionWithTarget<T: AnyObject, U: Any> : Subscriber {

    weak var target: T?
    let action: (T) -> (U) -> ()

    func broadcast(_ value: Any?) -> Bool {
        guard let t = target else { return false }
        guard let v = value as? U else { return true }
        action(t)(v)
        return true
    }

    func hasTarget(_ target: AnyObject) -> Bool {
        return self.target === target
    }
}


