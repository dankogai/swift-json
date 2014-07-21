swift-json
==========

Even Swiftier JSON Handler

Usage
-----

Just add `json.swift` to your project and have fun!

Synopsis
--------

Turn your swift object to JSON like so:

````swift
let obj:[String:AnyObject] = [
    "array": [JSON.null, false, 0, "",[],[:]],
    "object":[
        "null":   JSON.null,
        "bool":   true,
        "int":    42,
        "double": 3.141592653589793,
        "string": "a α\t弾\n𪚲",
        "array":  [],
        "object": [:]
    ],
    "url":"http://blog.livedoor.com/dankogai/"
]

let json = JSON(obj)
json.toString()
// "{\"array\":[null,false,0,\"\",[],{}],
//  \"object\":{\"int\":42,\"double\":3.141592653589793,
//  \"string\":\"a α\t弾\n𪚲\",\"object\":{},\"null\":null,
//  \"bool\":true,\"array\":[]},
//  \"url\":\"http://blog.livedoor.com/dankogai/\"}"
````

...or string...

````swift
let json = JSON.parse("{\"array\":[...}")
````

...or URL.

````swift
let json = JSON.fromURL("http://api.dan.co.jp/jsonenv")
````

### Tree Traversal

Just traverse elements via subscript:

````swift
json["object"]["null"].asNull       // NSNull()
json["object"]["bool"].asBool       // true
json["object"]["int"].asInt         // 42
json["object"]["double"].asDouble   // 3.141592653589793
json["object"]["string"].asString   // "a α\t弾\n𪚲"
````

````swift
json["array"][0].asNull             // NSNull()
json["array"][1].asBool             // false
json["array"][2].asInt              // 0
json["array"][3].asString           // ""
````

Don't worry if the subscripted entry does not exist.  Just like [SwiftyJSON] it simply turns into the error object.  Call that NSError Chain :-?

[SwiftyJSON]: https://github.com/lingoer/SwiftyJSON
````swift
if let b = json["noexistent"][1234567890]["entry"].asBool {
    // ....
} else {
    let e = json["noexistent"][1234567890]["entry"].asError
    println(e)
} // Error Domain=JSONErrorDomain Code=404 "["noexistent"] not found" UserInfo=0x10064bfc0 {NSLocalizedDescription=["noexistent"] not found}
````

### Custom Accessors via Inheritance

But you still need subscripts to traverse an object (dictionary in Swift, that is).  In JavaScript where JSON is originated, You don't need subscripts for string keys.  They automagically turns into property names.

````JavaScript
//json["object"]["string"] vs...
  json.object.string
````

4 characters for each array or object!  Can't we teach Swift how to access via methods?

Yes, we can!

````swift
//// schema by subclassing
class MyJSON : JSON {
    init(_ obj:AnyObject){ super.init(obj) }
    init(_ json:JSON)  { super.init(json) }
    var null  :NSNull? { return self["null"].asNull }
    var bool  :Bool?   { return self["bool"].asBool }
    var int   :Int?    { return self["int"].asInt }
    var double:Double? { return self["double"].asDouble }
    var string:String? { return self["string"].asString }
    var url:   String? { return self["url"].asString }
    var array :MyJSON  { return MyJSON(self["array"])  }
    var object:MyJSON  { return MyJSON(self["object"]) }
}
````

Now do:

````swift
let myjson = MyJSON(obj)
myjson.object.null      // NSNull?
myjson.object.bool      // Bool?
myjson.object.int       // Int?
myjson.object.double    // Double?
myjson.object.string    // String?
myjson.url              // String?
````

This approach comes with bonus.  You can't accidentaly access elements that was not supposed to there.  JSON is schemaless and that is what makes JSON rule today.  But that is also what makes JSON so prone to error.   With Swift and this `JSON` class you get the best of both worlds -- flexibility of JSON and robustness of static typing.


Description
===========

TBD.
