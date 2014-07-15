//
//  main.swift
//  json
//
//  Created by Dan Kogai on 7/15/14.
//  Copyright (c) 2014 Dan Kogai. All rights reserved.
//
//// for convenience
operator infix => { associativity left precedence 95 }
@infix func => <A,R> (lhs:A, rhs:A->R)->R {
    return rhs(lhs)
}
//// let the show begin!
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
let jstr = json.toString()
jstr == JSON.parse(jstr).toString()             => println
json                                            => println
json.toString(pretty: true)                     => println
json["object"]                                  => println
json["object"]["array"]                         => println
json["object"]["array"][0]                      => println
json["object"]["array"].count                   => println
json["object"]["object"][""]                    => println
json.keys                                       => println
json.count                                      => println
let object = json["object"]
object["null"].asNull       => println
object["bool"].asBool       => println
object["int"].asInt         => println
object["double"].asDouble   => println
object["string"].asString   => println
for (k, v) in json["array"] {
    "[\"array\"][\(k)] =>\t\(v)"        => println
}
for (k, v) in json["object"] {
    "[\"object\"][\"\(k)\"] =>\t\(v)"   => println
}
for (k, v) in json["url"] {
    "!!!! not supposed to see this!"    => println
}
json["wrong_key"][Int.max]["wrong_name"]    => println
//// schema by subclassing
class MyJSON : JSON {
    init(_ obj:AnyObject){ super.init(obj) }
    init(_ json:JSON) { super.init(json) }
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
myjson.toString() == jstr               => println
myjson.object                           => println
myjson.object.array                     => println
myjson.array                            => println
myjson.object.null      => println
myjson.object.bool      => println
myjson.object.int       => println
myjson.object.double    => println
myjson.object.string    => println
myjson.url              => println
////
var url = "http://api.dan.co.jp/asin/4534045220.json"
JSON.fromURL(url).toString(pretty:true)    => println
url = "http://api.dan.co.jp/nonexistent"
JSON.fromURL(url).toString(pretty:true)    => println

