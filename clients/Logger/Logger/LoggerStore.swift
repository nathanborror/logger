import Foundation
import LoggerKit

class LoggerStore: ObservableObject {
    @Published var state: LoggerState
    
    private var backend: LoggerMachineProtocol?
    private var decoder = JSONDecoder()
    
    init() {
        self.state = LoggerState(entries: [], error: nil)
        self.backend = nil
        
        let file = FileManager.document(named: "data.logger")
        print("➤ Loading Database: \(file)")
        
        var err: NSError?
        self.backend = LoggerNew(file.absoluteString, &err)
        if let err = err {
            print(err)
        }
        
        current()
    }
    
    func current() {
        apply(backend?.current())
    }
    
    func entryCreate(text: String, color: Int64) {
        apply(backend?.entryCreate(text, color: color))
    }
    
    func entryDelete(id: Int64) {
        apply(backend?.entryDelete(id))
    }
    
    func entrySearch(query: String) {
        apply(backend?.entrySearch(query))
    }
    
    private func apply(_ data: Data?) {
        guard let data = data else { return }
        guard let state = try? decoder.decode(LoggerState.self, from: data) else { return }
        self.state = state
    }
}

// MARK: - Types

struct LoggerState: Decodable {
    let entries: [Entry]
    let error: StateError?
}

struct Entry: Decodable, Identifiable, Equatable, Hashable {
    let id: Int64
    let text: String
    let color: Int64
    let created: Int64
    let modified: Int64
}

struct StateError: Decodable {
    let code: String
    let message: String
}

// MARK: - Extensions

//extension Entry {
//
//    var entities: [Entity] {
//        guard let regex = try? NSRegularExpression(pattern: "(#[a-zA-Z0-9_\\p{Arabic}\\p{N}]*)", options: []) else {
//            return []
//        }
//        let matches = regex.matches(in: text, options: [], range: NSMakeRange(0, text.count))
//
//        var out: [Entity] = matches.map {
//            let str = NSString(string: text).substring(with: NSRange(location: $0.range.location, length: $0.range.length ))
//            return Entity.tag(str)
//        }
//
//        let cleaned = regex.stringByReplacingMatches(in: text, options: [], range: NSMakeRange(0, text.count), withTemplate: "")
//        out.insert(.text(cleaned.trimmingCharacters(in: .whitespaces)), at: 0)
//
//        return out
//    }
//}
//
//enum Entity: Identifiable {
//    case text(String)
//    case tag(String)
//
//    var id: Int {
//        switch self {
//        case .text(let text):
//            return text.hash
//        case .tag(let tag):
//            return tag.hash
//        }
//    }
//}
