//
// main.swift
// json
//
// Created by Dan Kogai on 7/15/14.
// Copyright (c) 2014 Dan Kogai. All rights reserved.
//
import Foundation
//for convenience
infix operator => { associativity left precedence 95 }
func => <A,R> (lhs:A, rhs:A->R)->R {
    return rhs(lhs)
}
func printOut(a: Any) {
    print(a)
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
jstr => printOut
JSON(string:jstr).toString()
    == JSON.parse(jstr).toString()  => printOut
json.toString(true)             => printOut
json["object"]                          => printOut
json["object"]["array"]                 => printOut
json["object"]["array"][0]              => printOut
json["object"]["object"][""]            => printOut
json["array"]                           => printOut
let object = json["object"]
object["null"].isNull       => printOut
object["null"].asNull       => printOut
object["bool"].isBool       => printOut
object["bool"].asBool       => printOut
object["int"].isInt         => printOut
object["int"].asInt         => printOut
object["int"].asInt32       => printOut
object["int64"].isInt       => printOut
object["int64"].asInt       => printOut // clashes in 32-bit environment
//object["int64"].asInt32     => printOutln // clashes
object["int64"].asInt64     => printOut
object["double"].isDouble   => printOut
object["double"].asDouble   => printOut
object["double"].asFloat    => printOut
object["string"].asString   => printOut
json["array"].isArray       => printOut
json["array"].asArray       => printOut
json["array"].length        => printOut
json["object"].isDictionary => printOut
json["object"].asDictionary => printOut
json["object"].length       => printOut
for (k, v) in json["array"] {
    "[\"array\"][\(k)] =>\t\(v)"        => printOut
}
for (k, v) in json["object"] {
    "[\"object\"][\"\(k)\"] =>\t\(v)"   => printOut
}
for (k, v) in json["url"] {
    "!!!! not supposed to see this!"    => printOut
}
json["wrong_key"][Int.max]["wrong_name"]    => printOut
/// error handling
if let b = json["noexistent"][1234567890]["entry"].asBool {
    printOut(b);
} else {
    let e = json["noexistent"][1234567890]["entry"].asError
    printOut(e)
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
myjson.toString() == jstr   => printOut
myjson.object               => printOut
myjson.object.array         => printOut
myjson.array                => printOut
myjson.object.null          => printOut
myjson.object.bool          => printOut
myjson.object.int           => printOut
myjson.object.double        => printOut
myjson.object.string        => printOut
myjson.url                  => printOut
////
var url = "http://api.dan.co.jp/asin/4534045220.json"
JSON(url:url).toString(true)    => printOut
url = "http://api.dan.co.jp/nonexistent"
JSON(url:url).toString(true)    => printOut
/// https://github.com/dankogai/swift-json/issues/18
let jinj = JSON(JSON(["json in JSON", JSON(["json in JSON":JSON(true)])]))
jinj.toString()  => printOut
// Print Values and Keys.
json.allValues => printOut
json.allKeys => printOut