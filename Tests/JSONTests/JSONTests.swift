import XCTest
@testable import JSON

final class JSONTests: XCTestCase {
    func testBasic() {
        let json:JSON = [
            "null":     nil,
            "bool":     true,
            "int":      -42,
            "double":   42.195,
            "String":   "漢字、カタカナ、ひらがなと\"引用符\"の入ったstring😇",
            "array":    [nil, true, 1, "one", [1], ["one":1]],
            "object":   [
                "null":nil, "bool":false, "number":0, "string":"" ,"array":[], "object":[:]
            ],
            "url":"https://github.com/dankogai/"
        ]
        let str = json.description
        XCTAssertEqual(JSON(string:str), json)
    }
    static var allTests = [
        ("testBasic", testBasic),
    ]
}
