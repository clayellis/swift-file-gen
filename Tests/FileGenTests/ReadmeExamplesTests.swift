// Don't want to look dumb by providing examples in the readme that don't produce what they say they do, so let's test them 😉

@testable import FileGen
import XCTest

final class ReadmeExamplesTests: XCTestCase {
    func testReadmeBasics() {
        let file = File(name: "test.txt", contents: "Hello, World!")
        XCTAssertEqual(file.contents, "Hello, World!")
    }

    func testReadmeBuilderSyntax() {
        let file = File("queen.txt") {
            for _ in 1...3 {
                "Dum..."
            }
            "Another one bites the dust!"
        }

        XCTAssertEqual(file.contents, """
        Dum...
        Dum...
        Dum...
        Another one bites the dust!

        """)
    }

    func testReadmeLists() {
        let fruits = ["🍎", "🍑", "🍊", "🍉"]
        let file = File("shopping.txt") {
            List(fruits) { fruit in
                "- \(fruit)"
            }
        }

        XCTAssertEqual(file.contents, """
        - 🍎
        - 🍑
        - 🍊
        - 🍉

        """)
    }

    func testReadmeInterpolation() {
        enum Statics: InterpolationKey {}
        let methods = ["GET", "POST", "UPDATE", "DELETE"]
        let file = File("HTTPMethods.swift") {
            """
            import Foundation

            enum HTTPMethods {
                \(Statics.self)
            }
            """
        }.value(for: Statics.self) {
            List(methods, separatedBy: "\n") { method in
                """
                /// HTTP Method: `\(method)`
                static let \(method.lowercased()) = "\(method)"
                """
            }
        }

        XCTAssertEqual(file.contents, """
        import Foundation

        enum HTTPMethods {
            /// HTTP Method: `GET`
            static let get = "GET"

            /// HTTP Method: `POST`
            static let post = "POST"

            /// HTTP Method: `UPDATE`
            static let update = "UPDATE"

            /// HTTP Method: `DELETE`
            static let delete = "DELETE"
        }

        """)
    }
}
