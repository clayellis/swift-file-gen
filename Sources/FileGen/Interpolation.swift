import Foundation

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

struct InterpolatedContent: FileContent {
    var contents: String

    init(contents: String) {
        self.contents = contents
    }
}

public extension FileContent {
    func value(for key: any InterpolationKey.Type, @File.Builder value: () -> String) -> FileContent {
        InterpolatedContent(contents: contents.replacingOccurrences(of: key.key, withIndented: value()))
    }
}

public extension File {
    func value(for key: any InterpolationKey.Type, @File.Builder value: () -> String) -> File {
        File(name: name, contents: contents.replacingOccurrences(of: key.key, withIndented: value()))
    }
}

extension String {
    func replacingOccurrences(of match: any StringProtocol, withIndented replacement: any StringProtocol) -> String {
        operatingOnRanges(of: match) { matchRange, string in
            var start = string.startIndex
            var end = string.endIndex
            var contentsEnd = string.endIndex
            string.getLineStart(&start, end: &end, contentsEnd: &contentsEnd, for: matchRange)

            let indentation = string[start..<matchRange.lowerBound]

            let indentedReplacement = replacement
                .components(separatedBy: "\n")
                .map { $0.isEmpty ? $0 : indentation + $0 }
                .joined(separator: "\n")

            string.replaceSubrange(start..<matchRange.upperBound, with: indentedReplacement)
        }
    }

    func operatingOnRanges(
        of match: any StringProtocol,
        options mask: String.CompareOptions = [],
        range searchRange: Range<Self.Index>? = nil,
        locale: Locale? = nil,
        operation: (_ range: Range<Self.Index>, _ string: inout String) -> Void
    ) -> String {
        var copy = self
        var nextSearchRange = searchRange
        while let range = copy.range(of: match, options: mask, range: nextSearchRange, locale: locale) {
            operation(range, &copy)

            guard range.upperBound < copy.endIndex else {
                break
            }

            let lowerBound = range.lowerBound == copy.startIndex ? range.lowerBound : copy.index(before: range.lowerBound)

            nextSearchRange = lowerBound..<copy.endIndex
            if let searchRange {
                nextSearchRange = nextSearchRange?.clamped(to: searchRange)
            }
        }

        return copy
    }
}
