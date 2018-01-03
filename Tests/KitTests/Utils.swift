import XCTest
@testable import Kit

class TestTarget {

    let wait: Int // TODO: This is brittle, figure out how to remove it
    let callback: (State) -> Void

    private var callCount = 0

    init(wait: Int = 0, callback: @escaping (State) -> Void) {
        self.wait = wait
        self.callback = callback
    }

    func update(state: State) {
        guard callCount == wait else {
            callCount += 1
            return
        }
        callback(state)
    }
}

func open(_ filename: String) -> Data {
    guard let url = Bundle(identifier: "run.nathan.KitTests")?.url(forResource: filename, withExtension: nil) else {
        return Data()
    }
    guard let data = try? Data(contentsOf: url) else {
        return Data()
    }
    return data
}
