
# OBSOLETED by [swift-sion]

[swift-sion] can do all what `swift-json` can do plus:

* Handles [SION], which is a "JSON++" with support for more data types.
* Conversion betwen:
  * JSON
  * Property List
  * MsgPack
  * YAML (output only)

* https://github.com/dankogai/swift-sion

[swift-sion]: https://github.com/dankogai/swift-sion
[SION]: https://dankogai.github.io/SION
[MsgPack]: https://msgpack.org

[![Swift 4.1](https://img.shields.io/badge/swift-4.1-brightgreen.svg)](https://swift.org)
[![MIT LiCENSE](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![build status](https://secure.travis-ci.org/dankogai/swift-json.png)](http://travis-ci.org/dankogai/swift-json)

# swift-json

Handle JSON safely, fast, and expressively.  Completely rewritten from ground up for Swift 4 and Swift Package Manager.

## Synopsis

```swift
import JSON
let json:JSON = ["swift":["safe","fast","expressive"]]
```

## Description

This module is a lot like [SwiftyJSON] in functionality.  It wraps [JSONSerialization] nicely and intuitively.  But it differs in how to do so.

[SwiftyJSON]: https://github.com/SwiftyJSON/SwiftyJSON
[JSONSerialization]: https://developer.apple.com/documentation/foundation/jsonserialization

* SwiftyJSON's `JSON` is `struct`.  `JSON` of this module is `enum`
* SwiftyJSON keeps the output of `JSONSerialization.jsonObject` in its stored property and convert its value runtime.  `JSON` of this module is static.  Definitely Swiftier.
* SwiftyJSON's `JSON.swift` is over 1,500 lines while that of this module is less than 400 (as of this writing).  Since it is so compact you can use it without building framework.

### Initialization

You can build JSON directly as a literal…

```swift
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
```

…or String…

```swift
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
```

…or a content of the URL…

```swift
JSON(urlString:"https://api.github.com")
```

…or by decoding `Codable` data…

```swift
import Foundation
struct Point:Hashable, Codable { let (x, y):(Int, Int) }
var data = try JSONEncoder().encode(Point(x:3, y:4))
try JSONDecoder().decode(JSON.self, from:data)
```

### Conversion

once you have the JSON object, converting to other formats is simple.

to JSON string, all you need is stringify it.  .description or "\(json)" would be enough.

```swift
json.description
"\(json)"				// JSON is CustomStringConvertible
```

If you need `Data`, simply call `.data`.

```swift
json.data
```

If you want to feed it (back) to `Foundation` framework, call `.jsonObject`

```swift
let json4plist = json.pick{ !$0.isNull }    // remove null
let plistData = try PropertyListSerialization.data (
    fromPropertyList:json4plist.jsonObject,
    format:.xml,
    options:0
)
print(String(data:plistData, encoding:.utf8)!)
```

### Manipulation

a blank JSON Array is as simple as:

```swift
var json = JSON([])
```

and you can assign elements like an ordinary array

```swift
json[0] = nil
json[1] = true
json[2] = 1
```

note RHS literals are NOT `nil`, `true` and `1` but `.Null`, `.Bool(true)` and `.Number(1)`.  Therefore this does NOT work

```swift
let one = "one"
json[3] = one // error: cannot assign value of type 'String' to type 'JSON'
```

In which case you do this instead.

```swift
json[3].string = one
```

They are all getters and setters.

```swift
json[1].bool   = true
json[2].number = 1
json[3].string = "one"
json[4].array  = [1]
json[5].object = ["one":1]
```

As a getter they are optional which returns `nil` when the type mismaches.

```swift
json[1].bool    // Optional(true)
json[1].number  // nil
```

Therefore, you can mutate like so:

```swift
json[2].number! += 1            // now 2
json[3].string!.removeLast()    // now "on"
json[4].array!.append(2)        // now [1, 2]
json[5].object!["two"] = 2      // now ["one":1,"two":2]
```

When you assign values to JSON array with an out-of-bound index, it is automatically streched with unassigned elements set to `null`, just like an ECMAScript `Array`

```swift
json[10] = false	// json[6...9] are null
```

As you may have guessed by now, a blank JSON object(dictionary) is:

```
json = JSON([:])
```

And manipulate intuitively like so.

```swift
json["null"]    = nil		// not null
json["bool"]    = false
json["number"]  = 0
json["string"]  = ""
json["array"]   = []
json["object"]  = [:]		// not {}
```

#### deep traversal

`JSON` is a recursive data type.  For recursive data types, you need a recursive method that traverses the data deep down.  For that purpuse, `JSON` offers `.pick` and `.walk`.

`.pick` is a "`.deepFilter`" that filters recursively.  You've already seen it above.  It takes a filter function of type `(JSON)->Bool`.  That function is applied to all leaf values of the tree and leaves that do not meet the predicate are pruned.

```swift
// because property list does not accept null
let json4plist = json.pick{ !$0.isNull }
```

`.walk` is a `deepMap` that transforms recursively.  This one is a little harder because you have to consider what to do on node and leaves separately.  To make your life easier three different versions of `.walk` are provided.  The first one just takes a leaf node.

```swift
// square all numbers and leave anything else 
JSON([0,[1,[2,3,[4,5,6]]], true]).walk {
    guard let n = $0.number else { return $0 }
    return JSON(n * n)
}
```

The second forms just takes a node.  Instead of explaining it, let me show you how `.pick` is implemented by extending `JSON` with `.select` that does exactly the same as `.pick`.

```swift
extension JSON {
    func select(picker:(JSON)->Bool)->JSON {
        return self.walk{ node, pairs, depth in
            switch node.type {
            case .array:
                return .Array(pairs.map{ $0.1 }.filter({ picker($0) }) )
            case .object:
                var o = [Key:Value]()
                pairs.filter{ picker($0.1) }.forEach{ o[$0.0.key!] = $0.1 }
                return .Object(o)
            default:
                return .Error(.notIterable(node.type))
            }
        }
    }
}
```

And the last form takes both.  Unlike the previous ones this one can return other than `JSON`.  Here is a quick and dirty `.yaml` that emits a YAML.

```swift
extension JSON {
    var yaml:String {
        return self.walk(depth:0, collect:{ node, pairs, depth in
            let indent = Swift.String(repeating:"  ", count:depth)
            var result = ""
            switch node.type {
            case .array:
                guard !pairs.isEmpty else { return "[]"}
                result = pairs.map{ "- " + $0.1}.map{indent + $0}.joined(separator: "\n")
            case .object:
                guard !pairs.isEmpty else { return "{}"}
                result = pairs.sorted{ $0.0.key! < $1.0.key! }.map{
                    let k = $0.0.key!
                    let q = k.rangeOfCharacter(from: .newlines) != nil
                    return (q ? k.debugDescription : k) + ": "  + $0.1
                    }.map{indent + $0}.joined(separator: "\n")
            default:
                break   // never reaches here
            }
            return "\n" + result
        },visit:{
            if $0.isNull { return  "~" }
            if let s = $0.string {
                return s.rangeOfCharacter(from: .newlines) == nil ? s : s.debugDescription
            }
            return $0.description
        })
    }
}
```

### Protocol Conformance


* `JSON` is `Equatable` so you can check if two JSONs are the same.

```swift
JSON(string:foo) == JSON(urlString:"https://example.com/whereever")
```

* `JSON` is `Hashable` so you can use it as a dictionary key.

* `JSON` is `ExpressibleBy*Literal`.  That's why you can initialize w/ `variable:JSON` construct show above.

* `JSON` is `CustomStringConvertible` whose `.description` is always a valid JSON.

* `JSON` is `Codable`.  You can use this module instead of `JSONEncoder`.

* `JSON` is `Sequence`.  But when you iterate, be careful with the key.

```swift
let ja:JSON = [nil, true, 1, "one", [1], ["one":1]]
// wrong!
for v in ja {
	//
}
```

```swift
// right!
for (i, v) in ja {
	// i is NOT an Integer but KeyType.Index.
	// To access its value, say i.index
}
```

```swift
let jo:JSON = [
    "null":nil, "bool":false, "number":0, "string":"",
    "array":[], "object":[:]
]
for (k, v) in jo {
	// k is NOT an Integer but KeyType.Key.
	// To access its value, say i.key
}

```

That is because swift demands to return same `Element` type.  If you feel this counterintuitive, you can simply use `.array` or `.object`:

```swift
for v in ja.array! {
	// ...
}
```

```swift
for (k, v) in jo.object! {
	// ...
}

```

### Error handling

Once `init`ed, `JSON` never fails.  That is, it never becomes `nil`.  Instead of being failable or throwing exceptions, `JSON` has a special value `.Error(.ErrorType)` which propagates across the method invocations.  The following code examines the error should it happen.

```swift
if let e = json.error {
	debugPrint(e.type)
	if let nsError = e.nsError {
		// do anything with nsError
	}
}
```

## Usage

### build

```sh
$ git clone https://github.com/dankogai/swift-json.git
$ cd swift-json # the following assumes your $PWD is here
$ swift build
```

### REPL

Simply

```sh
$ scripts/run-repl.sh
```

or

```sh
$ swift build && swift -I.build/debug -L.build/debug -lJSON

```

and in your repl,

```sh
  1> import JSON
  2> let json:JSON = ["swift":["safe","fast","expressive"]]
json: JSON.JSON = Object {
  Object = 1 key/value pair {
    [0] = {
      key = "swift"
      value = Array {
        Array = 3 values {
          [0] = String {
            String = "safe"
          }
          [1] = String {
            String = "fast"
          }
          [2] = String {
            String = "expressive"
          }
        }
      }
    }
  }
}
```

### Xcode

Xcode project is deliberately excluded from the repository because it should be generated via `swift package generate-xcodeproj` . For convenience, you can

```sh
$ scripts/prep-xcode
```

And the Workspace opens up for you with Playground on top.  The playground is written as a manual.

### iOS and Swift Playground

Unfortunately Swift Package Manager does not support iOS.  To make matters worse Swift Playgrounds does not support modules.  But don't worry.  This module is so compact all you need is copy [JSON.swift].

[JSON.swift]: Sources/JSON/JSON.swift

In case of Swift Playgrounds just copy it under `Sources` folder.  If you are too lazy just run:


```sh
$ scripts/ios-prep.sh
```

and `iOS/JSON.playground` is all set.  You do not have to `import JSON` therein.

### From Your SwiftPM-Managed Projects

Add the following to the `dependencies` section:

```swift
.package(
  url: "https://github.com/dankogai/swift-json.git", from: "4.0.0"
)
```

and the following to the `.target` argument:

```swift
.target(
  name: "YourSwiftyPackage",
  dependencies: ["JSON"])
```

Now all you have to do is:

```swift
import JSON
```

in your code.  Enjoy!

## Prerequisite

Swift 4.1 or better, OS X or Linux to build.

