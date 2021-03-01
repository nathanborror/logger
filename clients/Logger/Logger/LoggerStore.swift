import Foundation
import LoggerKit

class LoggerStore: ObservableObject {
    @Published var state: ItemState
    
    private var entryBackend: LoggerStaterProtocol?
    private var documentBackend: LoggerStaterProtocol?
    
//    private var decoder = JSONDecoder()
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .customISO8601
        return decoder
    }
    
    init() {
        self.state = ItemState(items: [])
        self.entryBackend = nil
        self.documentBackend = nil
        
        load()
        current()
    }
    
    func load() {
        let file = FileManager.document(named: "data.logger")
        print("➤ Loading Database: \(file)")
        print("➤ Framework Version: \(LoggerVersion())")
        
//        self.entryBackend = LoggerNew("alpha", file.absoluteString)
        self.documentBackend = LoggerNew("beta", file.absoluteString)
    }
    
    func reload() {
        load()
        current()
    }
    
    // MARK: - Entry Backend
    
    func current() {
//        apply(entryData: entryBackend?.current())
        apply(documentData: documentBackend?.current())
    }
    
    func itemCreate(text: String, color: Int64) {
//        apply(entryData: entryBackend?.entryCreate(text, color: color))
        apply(documentData: documentBackend?.entryCreate(text, color: color))
    }
    
    func itemUpdate(id: Int64, text: String, color: Int64) {
//        apply(entryData: entryBackend?.entryUpdate(id, text: text, color: color))
        apply(documentData: documentBackend?.entryUpdate(id, text: text, color: color))
    }
    
    func itemDelete(id: Int64) {
//        apply(entryData: entryBackend?.entryDelete(id))
        apply(documentData: documentBackend?.entryDelete(id))
    }
    
    func itemSearch(query: String) {
//        apply(entryData: entryBackend?.entrySearch(query))
        apply(documentData: documentBackend?.entrySearch(query))
    }
    
    // MARK: - Private
    
    private func apply(entryData: Data?) {
        guard let data = entryData else { return }
        do {
            let resp = try decoder.decode(LoggerEntryResponse.self, from: data)
            apply(entryResponse: resp)
        } catch {
            print(error)
        }
    }
    
    private func apply(entryResponse: LoggerEntryResponse) {
        let items = entryResponse.entries.map { Item(id: $0.id, text: $0.text, color: $0.color) }
        self.state = ItemState(items: items)
    }
    
    private func apply(documentData: Data?) {
        guard let data = documentData else { return }
        do {
            let resp = try decoder.decode(LoggerDocumentResponse.self, from: data)
            apply(documentResponse: resp)
        } catch {
            print(error)
        }
    }
    
    private func apply(documentResponse: LoggerDocumentResponse) {
        let items = documentResponse.documents.map { Item(id: $0.id, text: $0.content.text, color: $0.content.meta.color) }
        self.state = ItemState(items: items)
    }
}

// MARK: - Frontend Types

struct ItemState {
    let items: [Item]
}

struct Item: Identifiable {
    let id: Int64
    let text: String
    let color: Int64
}

// MARK: - Backend Types

struct LoggerEntryResponse: Decodable {
    let entries: [LoggerEntry]
    let error: LoggerError?
}

struct LoggerEntry: Decodable, Identifiable {
    let id: Int64
    let text: String
    let color: Int64
    let created: Int64
    let modified: Int64
}

struct LoggerError: Decodable {
    let code: String
    let message: String
}

struct LoggerDocumentResponse: Decodable {
    let documents: [LoggerDocument]
    let error: LoggerError?
}

struct LoggerDocument: Decodable, Identifiable {
    let identifier: String
    let content: LoggerDocumentContent
    let history: [LoggerDocumentContent]

    var id: Int64 {
        Int64(identifier) ?? 0
    }
}

struct LoggerDocumentContent: Decodable {
    let text: String
    let meta: LoggerDocumentMeta
    let created: Date
    let modified: Date
}

struct LoggerDocumentMeta: Decodable {
    let contentType: String
    let tags: [String]
    let color: Int64
}
