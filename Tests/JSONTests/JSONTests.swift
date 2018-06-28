import XCTest
@testable import JSON

import Foundation

final class JSONTests: XCTestCase {
    let json0:JSON = [
        "null":     nil,
        "bool":     true,
        "int":      -42,
        "double":   42.1953125,
        "String":   "漢字、カタカナ、ひらがなと\"引用符\"の入ったstring😇",
        "array":    [nil, true, 1, "one", [1], ["one":1]],
        "object":   [
            "null":nil, "bool":false, "number":0, "string":"" ,"array":[], "object":[:]
        ],
        "url":"https://github.com/dankogai/"
    ]
    func testBasic() {
        let str = json0.description
        XCTAssertEqual(JSON(string:str), json0)
    }
    func testCodable() {
        let data1 = try! JSONEncoder().encode(json0)
        let json1 = try! JSONDecoder().decode(JSON.self, from:data1)
        XCTAssertEqual(json1, json0)
        
        struct Point:Hashable, Codable { let (x, y):(Int, Int) }
        let data2 = try! JSONEncoder().encode(Point(x:3, y:4))
        let json2:JSON = ["x":3, "y":4]
        XCTAssertEqual(try! JSONDecoder().decode(JSON.self, from:data2), json2)
    }
    static var allTests = [
        ("testBasic",   testBasic),
        ("testCodable", testCodable),
    ]
}
