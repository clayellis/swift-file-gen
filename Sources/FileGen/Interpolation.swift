public protocol InterpolationKey {}

extension InterpolationKey {
    static var key: String {
        "InterpolationKey.\(type(of: self))"
    }
}

extension String.StringInterpolation {
    public mutating func appendInterpolation(_ key: any InterpolationKey.Type) {
        appendInterpolation(key.key)
    }
}

public extension File {
    func value(for key: any InterpolationKey.Type, @File.Builder value: () -> String) -> File {
        guard let keyRange = contents.range(of: key.key) else {
            return self
        }

        var start = contents.startIndex
        var end = contents.endIndex
        var contentsEnd = contents.endIndex
        contents.getLineStart(&start, end: &end, contentsEnd: &contentsEnd, for: keyRange)

        let indentation = contents[start..<keyRange.lowerBound]

        let indentedValue = value()
            .components(separatedBy: "\n")
            .map { $0.isEmpty ? $0 : indentation + $0 }
            .joined(separator: "\n")

        var contents = contents
        contents.replaceSubrange(start..<keyRange.upperBound, with: indentedValue)
        return File(name: name, contents: contents)
    }
}
