//
//  json.swift
//  json
//
//  Created by Dan Kogai on 7/15/14.
//  Copyright (c) 2014 Dan Kogai. All rights reserved.
//

import Foundation

class JSON {
    let value:AnyObject
    @required init(_ obj:AnyObject) { self.value = obj }
    init(_ json:JSON){ self.value = json.value }
    class func parse(str:String)->JSON {
        var err:NSError?
        let enc = NSUTF8StringEncoding
        var obj:AnyObject? = NSJSONSerialization.JSONObjectWithData(
            str.dataUsingEncoding(enc), options:nil, error:&err
        )
        if err { return self(err!) }
        else   { return self(obj!) }
    }
    class func fromNSURL(nsurl:NSURL) -> JSON {
        var enc:NSStringEncoding = NSUTF8StringEncoding
        var err:NSError?
        let str:String? =
        NSString.stringWithContentsOfURL(
            nsurl, usedEncoding:&enc, error:&err
        )
        if err { return self(err!) }
        else   { return self.parse(str!) }
    }
    class func fromURL(url:String) -> JSON {
        return self.fromNSURL(NSURL.URLWithString(url))
    }
    class func stringify(obj:AnyObject, pretty:Bool=false) -> String {
        return self(obj).toString(pretty:pretty)
    }
    typealias NSNull = Foundation.NSNull
    class var null:NSNull { return NSNull() }
    var typeOf:String {
        switch value {
        case is NSNull:                 return "NSNull"
        case let o as NSNumber:
            switch o.objCType {
            case "c", "C":              return "Bool"
            case "q", "l", "i", "s":    return "Int"
            case "Q", "L", "I", "S":    return "UInt"
            default:                    return "Double"
                
        }
        case is NSString:               return "String"
        case is NSArray:                return "NSArray"
        case is NSDictionary:           return "NSDictionary"
        default:                        return "NSError"
        }
    }
    subscript(idx:Int) -> JSON {
        switch value {
        case let err as NSError:
            return JSON(err)
        case let ary as NSArray:
            if 0 <= idx && idx < ary.count {
                return JSON(ary[idx]!)
            }
            return JSON(NSError(
                domain:"JSONErrorDomain", code:404, userInfo:[
                    NSLocalizedDescriptionKey:
                        "[\(idx)] is out of range"
                ]))
        default:
            return JSON(NSError(
                domain:"JSONErrorDomain", code:500, userInfo:[
                    NSLocalizedDescriptionKey: "not an array"
                ]))
            }
    }
    subscript(key:String)->JSON {
        switch value {
        case let err as NSError:
            return JSON(err)
        case let dic as NSDictionary:
            if let val:AnyObject = dic[key] { return JSON(val) }
            return JSON(NSError(
                domain:"JSONErrorDomain", code:404, userInfo:[
                NSLocalizedDescriptionKey:
                    "[\"\(key)\"] not found"
            ]))
        default:
            return JSON(NSError(
                domain:"JSONErrorDomain", code:500, userInfo:[
                    NSLocalizedDescriptionKey: "not an object"
                ]))
        }
    }
    var asNull:NSNull? {
        return value is NSNull ? NSNull() : nil
    }
    var asBool:Bool? {
        switch value {
        case let o as NSNumber:
            switch o.objCType {
            case "c", "C":
                return Bool(o.boolValue)
            default:
                return nil
            }
        default: return nil
        }
    }
    var asInt:Int? {
        switch value {
        case let o as NSNumber:
            switch o.objCType {
            case "c", "C":
                return nil
            default:
                return Int(o.longLongValue)
            }
        default: return nil
        }
    }
    var asDouble:Double? {
        switch value {
        case let o as NSNumber:
            switch o.objCType {
            case "c", "C":
                return nil
            default:
                return Double(o.doubleValue)
            }
        default: return nil
        }
    }
    var asString:String? {
        switch value {
        case let o as NSString:
            return String(o)
        default: return nil
        }
    }
    var count:Int {
        switch value {
        case let o as NSArray:      return o.count
        case let o as NSDictionary: return o.count
        default:                    return 0
        }
    }
    var keys:[String] {
        switch value {
        case let o as NSDictionary:
            var result = [String]()
            for (k:AnyObject,_) in o { result += k as String }
            return result
        default:
            return []
        }
    }
}
extension JSON : Sequence {
    func generate()->GeneratorOf<(AnyObject,JSON)> {
        let count = self.count
        var i = -1
        switch value {
        case let o as NSArray:
            return GeneratorOf<(AnyObject, JSON)> {
                if ++i == count { return nil }
                return (i as AnyObject, JSON(o[i]))
            }
        case let o as NSDictionary:
            var ks = self.keys
        return GeneratorOf<(AnyObject, JSON)> {
                if ++i == count { return nil }
                return (ks[i] as AnyObject, JSON(o[ks[i]]))
            }
        default:
            return GeneratorOf<(AnyObject, JSON)>{ nil }
        }
    }
}
extension JSON : Printable {
    func toString(pretty:Bool=false)->String {
        switch value {
        case is NSError: return "\(value)"
        case is NSNull: return "null"
        case let o as NSNumber:
            switch o.objCType {
            case "c", "C":
                return o.boolValue.description
            case "q", "l", "i", "s":
                return o.longLongValue.description
            case "Q", "L", "I", "S":
                return o.unsignedLongLongValue.description
            default:
                switch o.doubleValue {
                case 0.0/0.0:   return "0.0/0.0"    // NaN
                case -1.0/0.0:  return "-1.0/0.0"   // -infinity
                case +1.0/0.0:  return "+1.0/0.0"   //  infinity
                default:
                    return o.doubleValue.description
                }
            }
        case let o as NSString:
            var s = ""
            for u in String(o).unicodeScalars {
                s += u.isASCII()
                    ? u.escape(asASCII: false) : String(u)
            }
            return "\"" + s + "\""
        default:
            let opts = pretty ? NSJSONWritingOptions.PrettyPrinted : nil
            let data = NSJSONSerialization.dataWithJSONObject(
                value, options:opts, error:nil
            )
            return NSString(
                data:data, encoding:NSUTF8StringEncoding
            )
        }
    }
    var description:String { return toString() }
}

