import XCTest
@testable import FileGen

final class FileGenTests: XCTestCase {
    func testFileInit() {
        let file = File(name: "test.txt", contents: "Hello, World!")
        XCTAssertEqual(file.name, "test.txt")
        XCTAssertEqual(file.contents, "Hello, World!")
    }

    func testFileDescription() {
        let file = File(name: "test.txt", contents: "Hello, World!")
        XCTAssertEqual(file.contents, file.description)
        XCTAssertEqual(file.contents, "Hello, World!")
        XCTAssertEqual(file.contents, "\(file)")
    }

    func testFileBuilderInit() {
        let file = File("test.txt") {
            "Hello, World!"
        }

        XCTAssertEqual(file.name, "test.txt")
        XCTAssertEqual(file.contents, "Hello, World!\n")
    }

    func testFileBuilderEndsWithNewline() {
        let file = File("test.txt", endWithNewline: false) {
            "Hello, World!"
        }

        XCTAssertEqual(file.contents, "Hello, World!")
    }

    func testFileBuilderAlreadyEndsWithNewline() {
        let file = File("test.txt") {
            "Hello, World!"
            ""
        }

        XCTAssertEqual(file.contents, "Hello, World!\n")
        XCTAssertNotEqual(file.contents, "Hello, World!\n\n")
    }

    func testFileBuilderMultipleLines() {
        let file = File("test.txt") {
            "One"
            "Two"
            "Three"
        }

        XCTAssertEqual(file.contents, "One\nTwo\nThree\n")
    }

    func testFileBuilderForIn() {
        let file = File("test.txt") {
            for n in 0...5 {
                "\(n)"
            }
        }

        XCTAssertEqual(file.contents, "0\n1\n2\n3\n4\n5\n")
    }

    func testTrimDefaultNewlines() {
        let beforeAndAfter = File("test.txt") {
            Trim {
                ""
                "Test"
                ""
            }
        }

        XCTAssertEqual(beforeAndAfter.contents, "Test\n")
        XCTAssertNotEqual(beforeAndAfter.contents, "\nTest\n\n")

        let justBefore = File("test.txt") {
            Trim {
                ""
                "Test"
            }
        }

        XCTAssertEqual(justBefore.contents, "Test\n")
        XCTAssertNotEqual(justBefore.contents, "\nTest\n")

        let justAfter = File("test.txt") {
            Trim {
                "Test"
                ""
            }
        }

        XCTAssertEqual(justAfter.contents, "Test\n")
        XCTAssertNotEqual(justAfter.contents, "Test\n\n")
    }

    func testTrimCustomCharacters() {
        let file = File("test.txt") {
            Trim(.decimalDigits) {
                "123Test456"
            }
        }

        XCTAssertEqual(file.contents, "Test\n")
        XCTAssertNotEqual(file.contents, "123Test456\n")
    }

    func testList() {
        let items = [1, 2, 3]
        let file = File("test.txt") {
            List(items) { item in
                "Item: \(item)"
            }
        }

        XCTAssertEqual(file.contents, """
        Item: 1
        Item: 2
        Item: 3

        """)
    }

    func testListNoSeparateLines() {
        let items = [1, 2, 3]
        let file = File("test.txt") {
            List(items, placeItemsOnSeparateLines: false) { item in
                "Item: \(item)"
            }
        }

        XCTAssertEqual(file.contents, """
        Item: 1Item: 2Item: 3

        """)
    }

    func testListCustomSeparator() {
        let items = [1, 2, 3]
        let file = File("test.txt") {
            List(items, separatedBy: "\n") { item in
                "Item: \(item)"
            }
        }

        XCTAssertEqual(file.contents, """
        Item: 1

        Item: 2

        Item: 3

        """)
    }

    func testListCustomSeparatorNoNewline() {
        let items = [1, 2, 3]
        let file = File("test.txt", endWithNewline: false) {
            List(items, separatedBy: "\n") { item in
                "Item: \(item)"
            }
        }

        XCTAssertEqual(file.contents, """
        Item: 1

        Item: 2

        Item: 3
        """)
    }

    func testInterpolation() {
        enum EnumCase: InterpolationKey {}

        let file = File("test.txt") {
            """
            import Framework

            enum Test {
                \(EnumCase.self)
            }
            """
        }.value(for: EnumCase.self) {
            "case test"
        }

        XCTAssertEqual(file.contents, """
        import Framework

        enum Test {
            case test
        }

        """)
    }

    func testInterpolationAllLinesIndented() {
        enum EnumCases: InterpolationKey {}

        let file = File("test.txt") {
            """
            import Framework

            enum Test {
                \(EnumCases.self)
            }
            """
        }.value(for: EnumCases.self) {
            """
            case one
            case two
            case three
            """
        }

        XCTAssertEqual(file.contents, """
        import Framework

        enum Test {
            case one
            case two
            case three
        }

        """)
    }

    func testComplexFile() {
        enum EnumCases: InterpolationKey {}
        enum Joined: InterpolationKey {}

        let enumCases = ["one", "two", "three"]

        let file = File("test.txt") {
            Trim {
            """


            import Framework

            enum Test: String {
                \(EnumCases.self)
            }

            extension Test {
                var joined: String {
                    [\(Joined.self)].joined(by: ", ")
                }
            }



            """
            }
        }.value(for: EnumCases.self) {
            List(enumCases, separatedBy: "\n") { enumCase in
                """
                /// This is case \(enumCase).
                case \(enumCase) = "\(enumCase.uppercased())"
                """
            }
        }.value(for: Joined.self) {
            List(enumCases, separatedBy: ", ", placeItemsOnSeparateLines: false) { enumCase in
                "\(enumCase).rawValue"
            }
        }

        XCTAssertEqual(file.contents, """
        import Framework

        enum Test: String {
            /// This is case one.
            case one = "ONE"

            /// This is case two.
            case two = "TWO"

            /// This is case three.
            case three = "THREE"
        }

        extension Test {
            var joined: String {
                [one.rawValue, two.rawValue, three.rawValue].joined(by: ", ")
            }
        }

        """)
    }
}
