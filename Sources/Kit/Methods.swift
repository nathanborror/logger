import Foundation

extension Kit {
    
    // MARK: - Markers

    public static func insert(marker text: String, color: Int? = nil) {
        var marker = Marker(text, color: color)
        manager.commit {
            $0.apply(marker: marker)
        }
    }

    public static func update(marker id: UUID, text: String, color: Int? = nil) {
        // TODO: Update marker
    }
    
    public static func remove(marker id: UUID) {
        // TODO: Remove marker
    }

    // MARK: - Helpers

    public static func clearError() {
        manager.commit { $0.error = nil }
    }
}
