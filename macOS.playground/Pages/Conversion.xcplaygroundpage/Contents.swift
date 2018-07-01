//: [Previous](@previous)
import JSON
//: ### Conversion
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

//: once you have the `JSON` object, converting to other formats is simple.
//:
//: to JSON string, all you need is stringify it.  `.description` or `"\(json)"`
//: would be enough.

json.description
"\(json)"

//: if you need `Data`, simply call `.data`

json.data

//: If you want to feed it to `Foundation` framework, call `.jsonObject`

import Foundation

do {
    let json4plist = json.pick{ !$0.isNull }    // remove null
    let plistData = try PropertyListSerialization.data (
        fromPropertyList:json4plist.jsonObject,
        format:.xml,
        options:0
    )
    print(String(data:plistData, encoding:.utf8)!)
} catch {
    print(error)
}

//: [Next](@next)
