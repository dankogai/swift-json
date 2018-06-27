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
JSON(string:str)!   // failable
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
String(data:data, encoding:.utf8)
try JSONDecoder().decode(JSON.self, from:data)
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
json["null"]    = nil
json["bool"]    = false
json["number"]  = 0
json["string"]  = ""
json["array"]   = []
json["object"]  = {}
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
import Complex
```

in your code.  Enjoy!

## Prerequisite

Swift 4.1 or better, OS X or Linux to build.

