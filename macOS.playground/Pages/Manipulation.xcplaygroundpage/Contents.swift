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
json["object"]  = [:]

//: #### deep traversal
//: `JSON` is a recursive data type.  For recursive data types, you need a recursive method that traverses the data deep down.  For that purpuse, `JSON` offers `.pick` and `.walk`.

//: `.pick` is a "`.deepFilter`" that filters recursively.  You've already seen it above.  It takes a filter function of type `(JSON)->Bool`.  That function is applied to all leaf values of the tree and leaves that do not meet the predicate are pruned.

// because property list does not accept null
let json4plist = json.pick{ !$0.isNull }


//: `.walk` is a `deepMap` that transforms recursively.  This one is a little harder because you have to consider what to do on node and leaves separately.  To make your life easier three different forms of `.walk` are provided.  The first one just takes a leaf.

JSON([0,[1,[2,3,[4,5,6]]], true]).walk {
    guard let n = $0.number else { return $0 }
    return JSON(n * n)
}

//: The second forms just takes a node.  Instead of explaining it, let me show you how `.pick` is implemented by extending `JSON` with `.select` that does exactly the same as `.pick`.

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

//: And the last form takes both.  Unlike the previous ones this one can return other than `JSON`.  Here is a quick and dirty `.yaml` that emits a YAML.

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

//: and the second one just takes a node.
//: 

//: [Next](@next)
