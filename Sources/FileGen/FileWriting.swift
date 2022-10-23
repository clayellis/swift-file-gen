import Foundation

public extension File {
    struct WriteError: Error {
        public let message: String
    }

    func write(into url: URL, attributes: [FileAttributeKey: Any]? = nil, using fileManager: FileManager = .default) throws {
        try write(to: url.appendingPathComponent(name), attributes: attributes, using: fileManager)
    }

    func write(to url: URL, attributes: [FileAttributeKey: Any]? = nil, using fileManager: FileManager = .default) throws {
        let success = fileManager.createFile(
            atPath: url.path,
            contents: contents.data(using: .utf8),
            attributes: attributes
        )

        guard success else {
            throw WriteError(message: "Failed to write file to \(url.path)")
        }
    }
}
