import Foundation

public extension File {
    struct WriteError: Error {
        public let message: String
    }

    func write(into url: URL, using fileManager: FileManager = .default) throws {
        try write(to: url.appendingPathComponent(name), using: fileManager)
    }

    func write(to url: URL, using fileManager: FileManager = .default) throws {
        let success = fileManager.createFile(
            atPath: url.path,
            contents: contents.data(using: .utf8)
        )

        guard success else {
            throw WriteError(message: "Failed to write file to \(url.path)")
        }
    }
}
