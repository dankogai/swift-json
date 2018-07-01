//: [Previous](@previous)

import JSON

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

let str = json.description

JSON(urlString:"http://api.github.com")
JSON(string:"true")
json["foo"]

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
