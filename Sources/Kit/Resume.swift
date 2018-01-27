import Foundation

extension State {
    
    // MARK: - Resume
    
    static func resume() -> State {
        return State(
            markers: resumeFakeMarkers(),
            error: nil
        )
    }

    static func resumeFakeMarkers() -> [UUID: Marker] {
        var out = [UUID: Marker]()
        for _ in 0..<30 {
            let marker = Marker("Lorem ipsum", color: 0x000000)
            out[marker.id] = marker
        }
        return out
    }

    static func resumeMarkers() -> [UUID: Marker] {
        let value = Keychain.shared["markers"]
        return decode(string: value) ?? [:]
    }
    
    // MARK: - Suspend
    
    func suspend() {
        suspendMarkers()
    }

    func suspendMarkers() {
        Keychain.shared["markers"] = encode(value: markers)
    }
    
    // MARK: - Helpers

    private func encode<T: Encodable>(value: T) -> String? {
        guard let data = try? JSONEncoder().encode(value) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    private static func decode<T: Decodable>(string: String?) -> T? {
        guard let data = string?.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
