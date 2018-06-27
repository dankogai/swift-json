import JSON
import Foundation


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

print(json0)
let data = try JSONEncoder().encode(json0)
let json1 = try JSONDecoder().decode(JSON.self, from:data)
print(json1)
print(json0 == json1)

struct Point:Hashable, Codable { let (x, y):(Int, Int) }

