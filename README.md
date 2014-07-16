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

Discussion
==========

The first approach to JSON from Swift was directly using what `NSJSONSerialization` has to offer.  Your code would like this:

exerpt from [SwiftyJSON]'s README

````swift
let jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(dataFromTwitter, options: NSJSONReadingOptions.MutableContainers, error: nil)
if let statusesArray = jsonObject as? NSArray{
    if let aStatus = statusesArray[0] as? NSDictionary{
        if let user = aStatus["user"] as? NSDictionary{
            if let userName = user["name"] as? NSDictionary{
                //Finally We Got The Name

            }
        }
    }
}
````
or this:

````swift
let jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(dataFromTwitter, options: NSJSONReadingOptions.MutableContainers, error: nil)
if let userName = (((jsonObject as? NSArray)?[0] as? NSDictionary)?["user"] as? NSDictionary)?["name"]{
  //What A disaster above
}
````

Then Swifty JSON comes along and changed everything.

````
let json = JSONValue(dataFromNetworking)
if let userName = json[0]["user"]["name"].string{
  //Now you got your value
}
````

Handsome, isn't it.  And SwiftyJSON's beauty is not skin deep.  Swift's enum rocks!

Or does it?

Swift offers three diffrent flavors of objects: `struct`, `enum` and `class`.  They can all have instance properties and type properties.  They are all extensible via `extension`.  They are all generics-aware.  Then what's the point?

Some thing must be copied by value and that's what `struct` is for.  In swifts primitives are `struct` that happens to fit in the register.  So is `enum`, which is really a union in disguise.  And as with C and friends enums are also copied by value.

Then what happend to copy-by-reference types?  Yes, `class`!.  Good old-fasioned OOP is there to stay.  In addition to efficiency, Swift's `class` offers some thing the rest of two do not:

Inheritance!

In Swift, only `class` is inheritable and that matters in a case like this.  Different schema for different JSON trees.  You can add methods to enum-based `JSONValue` but the change is global.  It's all or nothing.  I wanted something customizable for each JSON endpoint.  This piece of code was thus born.

Description
===========

TBD.
