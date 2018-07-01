//: [Previous](@previous)

import JSON

let json:JSON = [
    "bool":     true,
    "int":      -42,
    "double":   42.195,
    "string":   "漢字、カタカナ、ひらがなと\"引用符\"の入ったstring😇",
    "array":    [true, 1, "one", [1], ["one":1]],
    "object":   [
        "bool":false, "number":0, "string":"" ,"array":[], "object":[:]
    ],
    "url":"https://github.com/dankogai/"
]

let str = json.description

JSON(urlString:"http://api.github.com")
JSON(string:"true")
json["foo"]

import Foundation

//let plist = try PropertyListEncoder().encode(json)
//let data = try PropertyListSerialization.data(fromPropertyList:plist, format:.xml, options:0)
//do {
//    var data = try JSONEncoder().encode(json)
//    // let data = try PropertyListSerialization.data(fromPropertyList:json.jsonObject, format:.xml, options:0)
//    print(String(data:data, encoding:.utf8)!)
//} catch {
//    print(error)
//}

//var j = JSON([0,1,[3, 4],["five":5]]).walk {
//    if let n = $0.number { return .Number(n + 1) }
//    else { return $0 }
//}
//j


//for (k, v) in json["object"] {
//    print(k.key!, v)
//}
//for (k, v) in json["array"] {
//    print(k.index!, v)
//}
//for (k, v) in json["bool"] {
//    print(v)
//}
//JSON(["distance":42.195]) == JSON(string: "{\"distance\":42.195}")

print(json.toString(space:2))
//print(json.prettyPrinted)


//: [Next](@next)
