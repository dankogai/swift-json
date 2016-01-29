//
// main.swift
// json
//
// Created by Dan Kogai on 7/15/14.
// Copyright (c) 2014 Dan Kogai. All rights reserved.
//
import Foundation
let test = TAP()
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
test.eq(JSON(string:jstr), JSON.parse(jstr), "JSON(string:jstr)==JSON.parse(jstr)")
test.eq(json["object"], JSON.parse(jstr)["object"],                     "== object")
test.eq(json["object"]["null"], JSON.parse(jstr)["object"]["null"],     "== null")
test.eq(json["object"]["bool"], JSON.parse(jstr)["object"]["bool"],     "== bool")
test.eq(json["object"]["int"], JSON.parse(jstr)["object"]["int"],       "== int")
test.eq(json["object"]["int64"], JSON.parse(jstr)["object"]["int64"],   "== int64")
test.eq(json["object"]["double"], JSON.parse(jstr)["object"]["double"], "== double")
test.eq(json["object"]["string"], JSON.parse(jstr)["object"]["string"], "== string")
test.eq(json["array"], JSON.parse(jstr)["array"],                       "== array")
test.eq(json["object"]["array"], JSON.parse(jstr)["object"]["array"],   "== []")
test.eq(json["object"]["object"], JSON.parse(jstr)["object"]["object"], "== {}")
test.ne(json["nosuchkey"], JSON.parse(jstr)["nosuchkey"],               "error == error is always false")
test.eq(JSON(string:jstr).toString(),JSON.parse(jstr).toString(),       "== .toString()")
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
let myjson = MyJSON(string:jstr)
test.eq(myjson, json, "myjson == json")
test.eq(myjson.null,    json["null"].asNull,        "myjson.null == json[\"null\"]")
test.eq(myjson.bool,    json["bool"].asBool,        "myjson.bool == json[\"bool\"]")
test.eq(myjson.int,     json["int"].asInt,          "myjson.int == json[\"int\"]")
test.eq(myjson.double,  json["double"].asDouble,    "myjson.double == json[\"double\"]")
test.eq(myjson.string,  json["string"].asString,    "myjson.string == json[\"string\"]")
test.eq(myjson.array,   json["array"],              "myjson.array == json[\"array\"]")
test.eq(myjson.object,  json["object"],             "myjson.object == json[\"object\"]")
test.done()
