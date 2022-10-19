import Foundation

public struct File {
    public let name: String
    public let contents: String

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
