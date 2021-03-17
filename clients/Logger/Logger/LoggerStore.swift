import Foundation
import LoggerKit
import CoreLocation

class LoggerStore: ObservableObject {
    @Published var state: ItemState
    
    private var entryBackend: LoggerStaterProtocol?
    private var locationManager: CLLocationManager
    
    private var decoder = JSONDecoder()
    
    init() {
        self.state = ItemState(items: [])
        self.entryBackend = nil
        self.locationManager = CLLocationManager()
        
        load()
        current()
    }
    
    func load() {
        let file = FileManager.document(named: "data.logger")
        print("➤ Loading Database: \(file)")
        print("➤ Framework Version: \(LoggerVersion())")
        
        self.entryBackend = LoggerNew("production", file.absoluteString)
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    var currentCoordinates: CLLocationCoordinate2D? {
        guard locationManager.authorizationStatus == .authorizedWhenInUse,
              locationManager.authorizationStatus == .authorizedAlways else { return nil }
        return locationManager.location?.coordinate
    }
    
    func reload() {
        load()
        current()
    }
    
    // MARK: - Entry Backend
    
    func current() {
        apply(entryData: entryBackend?.current())
    }
    
    func itemCreate(text: String, color: Int64) {
        apply(entryData: entryBackend?.entryCreate(text, color: color))
    }
    
    func itemUpdate(id: Int64, text: String, color: Int64) {
        apply(entryData: entryBackend?.entryUpdate(id, text: text, color: color))
    }
    
    func itemDelete(id: Int64) {
        apply(entryData: entryBackend?.entryDelete(id))
    }
    
    func itemSearch(query: String) {
        apply(entryData: entryBackend?.entrySearch(query))
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
