import Cocoa    // this is an OSX playground
//: Playground - noun: a place where people can play

//for convenience
infix operator => { associativity left precedence 95 }
func => <A,R> (lhs:A, rhs:A->R)->R {
    return rhs(lhs)
}
var counter = 0;
func cout(a: Any) {
    print("\(counter):\t\(a)")
    counter++
}
//let the show begin!
let obj:[String:AnyObject] = [
    "array": [JSON.null, false, 0, "", [], [:]],
    "object":[
        "null":   JSON.null,
        "bool":   true,
        "int":    42,
        "int64":  NSNumber(longLong: 2305843009213693951), // for 32-bit environment
        "double": 3.141592653589793,
        "string": "a α\t弾\nð",
        "array":  [],
        "object": [:]
    ],
    "url":"http://blog.livedoor.com/dankogai/"
]
//
let json = JSON(obj)
let jstr = json.toString()
JSON(string:jstr).toString() == JSON.parse(jstr).toString()
json.toString(true)
json["object"]                          => cout
json["object"]["array"]                 => cout
json["object"]["array"][0]              => cout
json["object"]["object"][""]            => cout
json["array"]                           => cout
let object = json["object"]
object["null"].isNull       => cout
object["null"].asNull       => cout
object["bool"].isBool       => cout
object["bool"].asBool       => cout
object["int"].isInt         => cout
object["int"].asInt         => cout
object["int"].asInt32       => cout
object["int64"].isInt       => cout
//object["int64"].asInt       => cout // should crash in 32-bit environment
//object["int64"].asInt32     => cout // should crash in 64-bit environment
object["int64"].asInt64     => cout
object["double"].isDouble   => cout
object["double"].asDouble   => cout
object["double"].asFloat    => cout
object["string"].asString   => cout
json["array"].isArray       => cout
json["array"].asArray       => cout
json["array"].length        => cout
json["object"].isDictionary => cout
json["object"].asDictionary => cout
json["object"].length       => cout
for (k, v) in json["array"] {
    "[\"array\"][\(k)] =>\t\(v)"        => cout
}
for (k, v) in json["object"] {
    "[\"object\"][\"\(k)\"] =>\t\(v)"   => cout
}
for (k, v) in json["url"] {
    "!!!! not supposed to see this!"    => cout
}
json["wrong_key"][Int.max]["wrong_name"]    => cout
/// error handling
if let b = json["noexistent"][1234567890]["entry"].asBool {
    cout(b);
} else {
    let e = json["noexistent"][1234567890]["entry"].asError
    cout(e)
}
////  schema by subclassing
class MyJSON : JSON {
    override init(_ obj:AnyObject){ super.init(obj) }
    override init(_ json:JSON)  { super.init(json) }
    var null  :NSNull? { return self["null"].asNull }
    var bool  :Bool?   { return self["bool"].asBool }
    var int   :Int?    { return self["int"].asInt }
    var double:Double? { return self["double"].asDouble }
    var string:String? { return self["string"].asString }
    var url:   String? { return self["url"].asString }
    var array :MyJSON  { return MyJSON(self["array"])  }
    var object:MyJSON  { return MyJSON(self["object"]) }
}
let myjson = MyJSON(obj)
myjson.toString() == jstr   => cout
myjson.object               => cout
myjson.object.array         => cout
myjson.array                => cout
myjson.object.null          => cout
myjson.object.bool          => cout
myjson.object.int           => cout
myjson.object.double        => cout
myjson.object.string        => cout
myjson.url                  => cout
////
var url = "http://api.dan.co.jp/asin/4534045220.json"
JSON(url:url).toString(true)    => cout
url = "http://api.dan.co.jp/nonexistent"
JSON(url:url).toString(true)    => cout
/// https://github.com/dankogai/swift-json/issues/18
let jinj = JSON(JSON(["json in JSON", JSON(["json in JSON":JSON(true)])]))
jinj.toString()  => cout
// Print Values and Keys.
json.allValues => cout
json.allKeys => cout
