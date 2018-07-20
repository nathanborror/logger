import Foundation

extension FileManager {

    public static var database: URL {
        return url(for: .documentDirectory).appendingPathComponent("data.logger")
    }

    public static var photosDir: URL {
        return url(for: .documentDirectory, folder: "Photos")
    }

    public static var photosCacheDir: URL {
        return url(for: .cachesDirectory, folder: "Photos")
    }

    public static func url(for path: FileManager.SearchPathDirectory, folder: String? = nil) -> URL {
        var dir = try! FileManager.default.url(for: path, in: .userDomainMask, appropriateFor: nil, create: true)
        if let folder = folder {
            dir.appendPathComponent(folder, isDirectory: true)
            if FileManager.default.fileExists(atPath: dir.path) == false {
                try! FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            }
        }
        return dir
    }
}
