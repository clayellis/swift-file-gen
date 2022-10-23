import XCTest
@testable import FileGen

final class FileWritingTests: XCTestCase {

    let tests = URL(fileURLWithPath: FileManager.default.temporaryDirectory.appendingPathComponent("FileWritingTests").path)

    override func setUpWithError() throws {
        try deleteTestsDirectory()
        try FileManager.default.createDirectory(atPath: tests.path, withIntermediateDirectories: false)
    }

    override func tearDownWithError() throws {
        try deleteTestsDirectory()
    }

    func deleteTestsDirectory() throws {
        if FileManager.default.fileExists(atPath: tests.path) {
            do {
                try FileManager.default.removeItem(at: tests)
            } catch {
                print("Failed to delete test directory \(tests.path): \(error)")
            }
        }
    }

    func testFileWriteTo() throws {
        let file = File(name: "test.txt", contents: "Hello, World!")
        let writeURL = tests.appendingPathComponent("override.txt")
        try file.write(to: writeURL, attributes: [.immutable: true])
        XCTAssert(FileManager.default.fileExists(atPath: writeURL.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: tests.appendingPathComponent("test.txt").path))
        let contents = try XCTUnwrap(FileManager.default.contents(atPath: writeURL.path))
        XCTAssertEqual(file.contents, String(decoding: contents, as: UTF8.self))
        let attributes = try FileManager.default.attributesOfItem(atPath: writeURL.path)
        XCTAssertEqual(attributes[.immutable] as? Bool, true)
    }

    func testFileWriteInto() throws {
        let file = File(name: "test.txt", contents: "Hello, World!")
        let fileURL = tests.appendingPathComponent("test.txt")
        try file.write(into: tests, attributes: [.immutable: true])
        XCTAssert(FileManager.default.fileExists(atPath: fileURL.path))
        let contents = try XCTUnwrap(FileManager.default.contents(atPath: fileURL.path))
        XCTAssertEqual(file.contents, String(decoding: contents, as: UTF8.self))
    }

    func testFileWriteToThrows() throws {
        let file = File(name: "test.txt", contents: "Hello, World!")
        let doesNotExist = tests.appendingPathComponent("Bad", isDirectory: true)
        let fileURL = doesNotExist.appendingPathComponent("test.txt")

        var errorThrown: Error?
        try XCTAssertThrowsError(file.write(into: doesNotExist)) { error in
            errorThrown = error
        }
        let writeError = try XCTUnwrap(errorThrown as? File.WriteError)
        XCTAssertEqual(writeError.message, "Failed to write file to \(fileURL.path)")
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileURL.path))
    }
}
