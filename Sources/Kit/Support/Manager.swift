/// This is a generated file, do not edit

import Foundation

protocol NeedsUpdateable {
    associatedtype StateType
    func needsUpdate(new: StateType, prior: StateType) -> Bool
}

protocol ManagerInitable {

    associatedtype StateType
    init?(_: StateType) throws
}

public class Manager<StateType> {

    private(set) var state: StateType

    private var commitedState: StateType
    private var overlaidMutations: [(OverlayToken,Mutation)]
    private var tokenCounter: OverlayToken = 0
    private var stateSubs: Subscription<StateType>

    init(state: StateType) {
        self.state = state
        self.commitedState = state
        self.overlaidMutations = []
        self.stateSubs = Subscription<StateType>()
    }

    func subscribe<T: AnyObject>(_ target: T, action: @escaping (T) -> (StateType) -> ()) {
        stateSubs.subscribe(target, action: action)
    }

    func commit(mutation: Mutation) {
        var updatedState = commitedState
        mutation(&updatedState)
        commitedState = updatedState
        recompositeState()
        broadcastState()
    }

    func overlay(mutation: @escaping Mutation) -> OverlayToken {
        tokenCounter = tokenCounter + 1
        overlaidMutations.append((tokenCounter, mutation))
        recompositeState()
        broadcastState()
        return tokenCounter
    }

    func remove(overlay: OverlayToken) {
        overlaidMutations = overlaidMutations.filter { (t, _) in t != overlay }
        recompositeState()
        broadcastState()
    }

    private func recompositeState() {
        var accumulatedState = commitedState
        for (_, overlay) in overlaidMutations {
            overlay(&accumulatedState)
        }
        state = accumulatedState
    }

    private func broadcastState() {
        // TODO: Force on main thread for now
        stateSubs.broadcast(state)
    }

    typealias Mutation = (inout StateType) -> ()
    typealias OverlayToken = Int
}
