//: [Previous](@previous)
import JSON
//: ### Initialization
//:
//: You can build JSON directly as a literal…
let json:JSON = [
    "null":     nil,
    "bool":     true,
    "int":      -42,
    "double":   42.195,
    "string":   "漢字、カタカナ、ひらがなと\"引用符\"の入ったstring😇",
    "array":    [nil, true, 1, "one", [1], ["one":1]],
    "object":   [
        "null":nil, "bool":false, "number":0, "string":"" ,"array":[], "object":[:]
    ],
    "url":"https://github.com/dankogai/"
]

//: …or String…
let str = """
{
    "null":     null,
    "bool":     true,
    "int":      -42,
    "double":   42.195,
    "string":   "漢字、カタカナ、ひらがなと\\"引用符\\"の入ったstring😇",
    "array":    [null, true, 1, "one", [1], {"one":1}],
    "object":   {
        "null":null, "bool":false, "number":0, "string":"" ,"array":[], "object":{}
    },
    "url":"https://github.com/dankogai/"
}
"""
JSON(string:str)

//: …or a content of the URL…
JSON(urlString:"https://api.github.com")

//: …or by decoding Codable data…
import Foundation
struct Point:Hashable, Codable { let (x, y):(Int, Int) }
var data = try JSONEncoder().encode(Point(x:3, y:4))
String(data:data, encoding:.utf8)
try JSONDecoder().decode(JSON.self, from:data)

//: [Next](@next)
