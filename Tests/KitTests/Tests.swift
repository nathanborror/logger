import XCTest
@testable import Kit

class SearchTests: XCTestCase {

    var session: MockRemoteSession!

    override func setUp() {
        super.setUp()
        session = MockRemoteSession()
        Kit.replace(service: Service(State(), session: session))
    }

    override func tearDown() {
        super.tearDown()
        session = nil
    }

    func testFoo() {
    }
}
