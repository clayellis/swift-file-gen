import Foundation

public struct Trim: FileContent {
    let characterSetToTrim: CharacterSet
    public let contents: String

    public init(_ characterSetToTrim: CharacterSet = .newlines, @File.Builder contents: () -> String) {
        self.characterSetToTrim = characterSetToTrim
        self.contents = contents().trimmingCharacters(in: characterSetToTrim)
    }

    public init(_ characters: String, @File.Builder contents: () -> String) {
        self.init(CharacterSet(characters.unicodeScalars), contents: contents)
    }
}
