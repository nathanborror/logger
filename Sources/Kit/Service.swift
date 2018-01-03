import Foundation

public struct Kit {

    public static var images: Images { return shared.images }

    internal static var shared: Service = Service(State.resume())
    internal static var manager: Manager<State> { return shared.manager }
    internal static var messages: Messages { return shared.messages }

    static func replace(service: Service) {
        shared = service
    }

    public static func suspend() {
        manager.state.suspend()
    }

    public static func subscribe<T: AnyObject>(_ target: T, action: @escaping (T) -> (State) -> ()) {
        shared.subsState.subscribe(target, action: action)
        action(target)(manager.state)
    }

    public static func subscribe<T: AnyObject>(_ target: T, action: @escaping (T) -> ([Message]) -> ()) {
        shared.subsMessages.subscribe(target, action: action)
        action(target)(messages.read())
    }
}

public class Service {

    internal var manager: Manager<State>
    internal var messages: Messages
    internal var images: Images
    internal var subsState: Subscription<State>
    internal var subsMessages: Subscription<[Message]>

    init(_ state: State) {
        self.manager = Manager(state: state)
        self.messages = Messages()
        self.images = Images()
        self.subsState = Subscription<State>()
        self.subsMessages = Subscription<[Message]>()

        self.manager.subscribe(self, action: Service.stateChange)
        self.messages.subscribe(self, action: Service.messagesChange)
    }

    private func stateChange(state: State) {
        subsState.broadcast(state)
    }

    private func messagesChange(messages: Messages) {
        subsMessages.broadcast(messages.read())
    }
}
