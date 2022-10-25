import XCTest
@testable import FileGen

final class FileWritingTests: XCTestCase {

    let tests = URL(fileURLWithPath: FileManager.default.temporaryDirectory.appendingPathComponent("FileWritingTests").path)

    override func setUpWithError() throws {
        try deleteTestsDirectory()
        try FileManager.default.createDirectory(atPath: tests.path, withIntermediateDirectories: true)
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
        let writeURL = tests.appendingPathComponent(file.name)
        XCTAssertFalse(FileManager.default.fileExists(atPath: writeURL.path))
        try file.write(to: writeURL, attributes: [:])
        XCTAssert(FileManager.default.fileExists(atPath: writeURL.path))
        let contents = try XCTUnwrap(FileManager.default.contents(atPath: writeURL.path))
        XCTAssertEqual(file.contents, String(decoding: contents, as: UTF8.self))
    }

    func testFileWriteInto() throws {
        let file = File(name: "test.txt", contents: "Hello, World!")
        let fileURL = tests.appendingPathComponent("test.txt")
        try file.write(into: tests, attributes: [:])
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

    func testWriteToLockedFile() throws {
        var lockedFile = File(name: "locked.txt", contents: "🔒")
        let fileURL = tests.appendingPathComponent(lockedFile.name)
        // Clean up after this test
        defer {
            do {
                try FileManager.default.setAttributes([.immutable: false], ofItemAtPath: fileURL.path)
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("Failed to delete \(fileURL.path)")
            }
        }
        // Write the file and with locked attributes
        try lockedFile.write(to: fileURL, attributes: [.immutable: true])
        // The file should not be writable
        XCTAssertFalse(FileManager.default.isWritableFile(atPath: fileURL.path))
        // Adjust the contents
        lockedFile.contents = "🔓"
        // Attempting to write the changes without unlocking should fail
        try XCTAssertThrowsError(lockedFile.write(to: fileURL, unlockingIfLocked: false))
        // But writing while unlocking should succeed
        try XCTAssertNoThrow(lockedFile.write(to: fileURL, unlockingIfLocked: true))
        // The file should be relocked
        XCTAssertFalse(FileManager.default.isWritableFile(atPath: fileURL.path))
        // The file's contents should be updated
        let lockedFileContents = FileManager.default.contents(atPath: fileURL.path)
            .map { String(decoding: $0, as: UTF8.self) }
        XCTAssertEqual(lockedFileContents, "🔓")
    }
}
