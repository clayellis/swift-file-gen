import Foundation

public struct File {
    public let name: String
    public var contents: String

    public init(name: String, contents: String) {
        self.name = name
        self.contents = contents
    }
}

extension File: CustomStringConvertible {
    public var description: String {
        contents
    }
}
