public protocol FileContent {
    var contents: String { get }
}

extension String: FileContent {
    public var contents: String { self }
}

public extension File {
    init(_ name: String, endWithNewline: Bool = true, @File.Builder contents: () -> String) {
        self.name = name
        let contents = contents()
        if endWithNewline, !contents.hasSuffix("\n") {
            self.contents = contents + "\n"
        } else {
            self.contents = contents
        }
    }

    @resultBuilder
    struct Builder {
        public static func buildBlock(_ components: FileContent...) -> String {
            components.map(\.contents).joined(separator: "\n")
        }

        public static func buildArray(_ components: [FileContent]) -> String {
            components.map(\.contents).joined(separator: "\n")
        }
    }
}
