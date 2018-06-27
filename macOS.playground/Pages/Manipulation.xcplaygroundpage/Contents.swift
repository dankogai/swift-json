//: [Previous](@previous)
//: ### Manipulation
import JSON

//: a blank JSON Array is as simple as:
var json = JSON([])
//: and you can assign elements like an ordinary array
json[0] = nil
json[1] = true
json[2] = 1
//: note RHS literals are NOT `nil`, `true` and `1` but `.Null`, `.Bool(true)` and `.Number(1)`.
//: so this does NOT work
let one = "one"
//json[3] = one // error: cannot assign value of type 'String' to type 'JSON'
//: in which case you can do the following:
json[3].string = one
//: they are all getters and setters.
json[1].bool   = true
json[2].number = 1
json[3].string = "one"
json[4].array  = [1]
json[5].object = ["one":1]
//: As a getter they are optional which returns `nil` when the type mismaches.
json[1].bool    // Optional(true)
json[1].number  // nil
//: Therefore, you can mutate like so:
json[2].number! += 1            // now 2
json[3].string!.removeLast()    // now "on"
json[4].array!.append(2)        // now [1, 2]
json[5].object!["two"] = 2      // now ["one":1,"two":2]
//: when you assign values to JSON array with an out-of-bound index, it is automatically streched with unassigned elements set to `null`, just like an ECMAScript `Array`
json[10] = false
json[9]
json
//: As you may have guessed by now, a blank JSON object(dictionary) is:
json = JSON([:])
//: and manipulate intuitively
json["null"]    = nil
json["bool"]    = false
json["number"]  = 0
json["string"]  = ""
json["array"]   = []
json["object"]  = {}

//: [Next](@next)
