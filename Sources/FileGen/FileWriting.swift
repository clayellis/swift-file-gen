import Foundation

public extension File {
    struct WriteError: Error {
        public let message: String
    }

    func write(into url: URL, unlockingIfLocked shouldUnlock: Bool = true, attributes: [FileAttributeKey: Any]? = nil, using fileManager: FileManager = .default) throws {
        try write(to: url.appendingPathComponent(name), unlockingIfLocked: shouldUnlock, attributes: attributes, using: fileManager)
    }

    func write(to url: URL, unlockingIfLocked shouldUnlock: Bool = true, attributes: [FileAttributeKey: Any]? = nil, using fileManager: FileManager = .default) throws {
        var attributesToReset = [FileAttributeKey: Bool]()

        defer {
            // Reset the attributes that were unset in order to unlock the file
            try? fileManager.setAttributes(attributesToReset, ofItemAtPath: url.path)
        }

        if fileManager.fileExists(atPath: url.path), !fileManager.isWritableFile(atPath: url.path), shouldUnlock {
            let fileAttributes = try fileManager.attributesOfItem(atPath: url.path)
            var attributesToUnset = [FileAttributeKey: Bool]()

            if fileAttributes[.immutable] as? Bool == true {
                attributesToUnset[.immutable] = false
            }

            if fileAttributes[.appendOnly] as? Bool == true {
                attributesToUnset[.appendOnly] = false
            }

            attributesToReset = attributesToUnset
                // Flip the flag back on
                .mapValues { !$0 }
                // Take out any attributes that were explicitly passed in
                .filter { attributes?[$0.key] == nil }

            // Unlock the file
            try fileManager.setAttributes(attributesToUnset, ofItemAtPath: url.path)
        }

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
