//
//  json.swift
//  json
//
//  Created by Dan Kogai on 7/15/14.
//  Copyright (c) 2014-2018 Dan Kogai. All rights reserved.
//

import Foundation

public enum JSON:Equatable {
    public enum JSONError : Equatable {
        case notAJSONObject
        case typeMismatch(JSON.ContentType)
        case indexOutOfRange(JSON.Index)
        case keyNonexistent(JSON.Key)
        case nsError(NSError)
    }
    public typealias Key        = String
    public typealias Value      = JSON
    public typealias Index      = Int
    case Error(JSONError)
    case Null
    case Bool(Bool)
    case Number(Double)
    case String(String)
    case Array([Value])
    case Object([Key:Value])
}
extension JSON : Hashable {
    public var hashValue: Int {
        switch self {
        case .Error(let m):     fatalError("\(m)")
        case .Null:             return NSNull().hashValue
        case .Bool(let v):      return v.hashValue
        case .Number(let v):    return v.hashValue
        case .String(let v):    return v.hashValue
        case .Array(let v):     return "\(v)".hashValue // will be fixed in Swift 4.2
        case .Object(let v):    return "\(v)".hashValue // will be fixed in Swift 4.2
        }
    }
}
extension JSON : CustomStringConvertible {
    public var description:String {
        switch self {
        case .Error(let m):     return ".Error(\"\(m)\")"
        case .Null:             return "null"
        case .Bool(let v):      return v.description
        case .Number(let v):    return v.description
        case .String(let v):    return v.debugDescription
        case .Array(let a):
            return "[" + a.map{ $0.description }.joined(separator:",") + "]"
        case .Object(let o):
            var ds = [Swift.String]()
            for (k, v) in o {
                ds.append(k.debugDescription + ":" + v.description)
            }
            return "{" + ds.joined(separator:",") + "}"
        }
    }
}
// Inits
extension JSON :
    ExpressibleByNilLiteral, ExpressibleByBooleanLiteral,
    ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral,
    ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    public init()                               { self = .Null }
    public init(nilLiteral: ())                 { self = .Null }
    public typealias BooleanLiteralType = Bool
    public init(_ value:Bool)                   { self = .Bool(value) }
    public init(booleanLiteral value: Bool)     { self = .Bool(value) }
    public typealias FloatLiteralType = Double
    public init(_ value:Double)                 { self = .Number(value) }
    public init(floatLiteral value:Double)      { self = .Number(value) }
    public typealias IntegerLiteralType = Int
    public init(_ value:Int)                    { self = .Number(Double(value)) }
    public init(integerLiteral value: Int)      { self = .Number(Double(value)) }
    public typealias StringLiteralType = String
    public init(_ value:String)                 { self = .String(value) }
    public init(stringLiteral value:String)     { self = .String(value) }
    public typealias ArrayLiteralElement = Value
    public init(_ value:[Value])                { self = .Array(value)  }
    public init(arrayLiteral value:JSON...)     { self = .Array(value)  }
    public init(_ value:[Key:Value])            { self = .Object(value) }
    public init(dictionaryLiteral value:(Key,Value)...) {
        var o = [Key:Value]()
        value.forEach { o[$0.0] = $0.1 }
        self = .Object(o)
    }
}
extension JSON {
    public init(jsonObject:Any?) {
        switch jsonObject {
        // Be careful! JSONSerialization renders bool as NSNumber use .objcType to tell the difference
        case let a as NSNumber:
            switch Swift.String(cString:a.objCType) {
            case "c", "C":  self = .Bool(a as! Bool)
            default:        self = .Number(a as! Double)
            }
        case nil:               self = .Null
        case let a as String:   self = .String(a)
        case let a as [Any?]:   self = .Array(a.map{ JSON(jsonObject:$0) })
        case let a as [Key:Any?]:
            var o = [Key:Value]()
            a.forEach{ o[$0.0] = JSON(jsonObject:$0.1) }
            self = .Object(o)
        default:
            self = .Error(.notAJSONObject)
        }
    }
    public init(data:Data) {
        do {
            let jo = try JSONSerialization.jsonObject(with:data, options:[.allowFragments])
            self.init(jsonObject:jo)
        } catch {
            self = .Error(.nsError(error as NSError))
        }
    }
    public init(string:String) {
        self.init(data:string.data(using:.utf8)!)
    }
    public init(urlString:String) {
        if let url = URL(string: urlString) {
            self = JSON(url:url)
        } else {
            self = JSON.Null
        }
    }
    public init(url:URL) {
        do {
            let str = try Swift.String(contentsOf: url)
            self = JSON(string:str)
        } catch {
            self = .Error(.nsError(error as NSError))
        }
    }
    public var data:Data {
        return self.description.data(using:.utf8)!
    }
    public var jsonObject:Any {
        return try! JSONSerialization.jsonObject(with:self.data)
    }
    public func formatted(option:
        JSONSerialization.WritingOptions=JSONSerialization.WritingOptions(rawValue: 0)
        )->String {
        let data = try! JSONSerialization.data(withJSONObject:self.jsonObject, options: option)
        return Swift.String(data: data, encoding: .utf8)!
    }
    public var prettyPrinted:String {
        return self.formatted(option:[.prettyPrinted])
    }
}
extension JSON {
    public enum ContentType {
        case error, null, bool, number, string, array, object
    }
    public var type:ContentType {
        switch self {
        case .Error(_):     return .error
        case .Null:         return .null
        case .Bool(_):      return .bool
        case .Number(_):    return .number
        case .String(_):    return .string
        case .Array(_):     return .array
        case .Object(_):    return .object
        }
    }
    public var isNull:Bool          { return type == .null }
    public var error:JSONError?     { switch self { case .Error(let v): return v default: return nil } }
    public var bool:Bool? {
        get { switch self { case .Bool(let v):  return v default: return nil } }
        set { self = .Bool(newValue!) }
    }
    public var number:Double? {
        get { switch self { case .Number(let v):return v default: return nil } }
        set { self = .Number(newValue!) }
    }
    public var string:String? {
        get { switch self { case .String(let v):return v default: return nil } }
        set { self = .String(newValue!) }
    }
    public var array:[Value]? {
        get { switch self { case .Array(let v): return v default: return nil } }
        set { self = .Array(newValue!) }
    }
    public var object:[Key:Value]?  {
        get { switch self { case .Object(let v):return v default: return nil } }
        set { self = .Object(newValue!) }
    }
}
extension JSON {
    public subscript(_ idx:Index)->JSON {
        get {
            switch self {
            case .Array(let a):
                guard idx < a.count else { return .Error(.indexOutOfRange(idx)) }
                return a[idx]
            default:
                return .Error(.typeMismatch(self.type))
            }
        }
        set {
            switch self {
            case .Array(var a):
                if idx < a.count {
                    a[idx] = newValue
                } else {
                    for _ in a.count ..< idx {
                        a.append(.Null)
                    }
                    a.append(newValue)
                }
                self = .Array(a)
            default:
                fatalError("\"\(self)\" is not an array")
            }
        }
    }
    public subscript(_ key:Key)->JSON {
        get {
            switch self {
            case .Object(let o):
                return o[key] ?? .Error(.keyNonexistent(key))
            default:
                return .Error(.typeMismatch(self.type))
            }
        }
        set {
            switch self {
            case .Object(var o):
                o[key] = newValue
                self = .Object(o)
            default:
                fatalError("\"\(self)\" is not an object")
            }
        }
    }
}
extension JSON : Sequence {
    public enum IteratorKey {
        case Index(Int)
        case Key(String)
        public var index:Int?  { switch self { case .Index(let v): return v default: return nil } }
        public var key:String? { switch self { case .Key(let v):   return v default: return nil } }
    }
    public typealias Element = (IteratorKey,JSON)  // for Sequence conformance
    public typealias Iterator = AnyIterator<Element>
    public func makeIterator() -> AnyIterator<JSON.Element> {
        switch self {
        case .Array(let a):
            var i = -1
            return AnyIterator {
                i += 1
                return a.count <= i ? nil : (IteratorKey.Index(i), a[i])
            }
        case .Object(let o):
            var kv = o.map{ $0 }
            var i = -1
            return AnyIterator {
                i += 1
                return kv.count <= i ? nil : (IteratorKey.Key(kv[i].0), kv[i].1)
            }
        default:
            return AnyIterator { nil }
        }
    }
}
extension JSON : Codable {
    private static let codableTypes:[Codable.Type] = [
        [Key:Value].self, [Value].self,
        Swift.String.self,
        Swift.Bool.self,
        UInt.self, Int.self,
        Double.self, Float.self,
        UInt64.self, UInt32.self, UInt16.self, UInt8.self,
        Int64.self,  Int32.self,  Int16.self,  Int8.self,
    ]
    public init(from decoder: Decoder) throws {
        if let c = try? decoder.singleValueContainer(), !c.decodeNil() {
            for type in JSON.codableTypes {
                switch type {
                case let t as Swift.Bool.Type:  if let v = try? c.decode(t) { self = .Bool(v); return }
                case let t as Int.Type:         if let v = try? c.decode(t) { self = .Number(Double(v)); return }
                case let t as Int8.Type:        if let v = try? c.decode(t) { self = .Number(Double(v)); return }
                case let t as Int32.Type:       if let v = try? c.decode(t) { self = .Number(Double(v)); return }
                case let t as Int64.Type:       if let v = try? c.decode(t) { self = .Number(Double(v)); return }
                case let t as UInt.Type:        if let v = try? c.decode(t) { self = .Number(Double(v)); return }
                case let t as UInt8.Type:       if let v = try? c.decode(t) { self = .Number(Double(v)); return }
                case let t as UInt16.Type:      if let v = try? c.decode(t) { self = .Number(Double(v)); return }
                case let t as UInt32.Type:      if let v = try? c.decode(t) { self = .Number(Double(v)); return }
                case let t as UInt64.Type:      if let v = try? c.decode(t) { self = .Number(Double(v)); return }
                case let t as Float.Type:       if let v = try? c.decode(t) { self = .Number(Double(v)); return }
                case let t as Double.Type:      if let v = try? c.decode(t) { self = .Number(v); return }
                case let t as Swift.String.Type:if let v = try? c.decode(t) { self = .String(v); return }
                case let t as [Value].Type:     if let v = try? c.decode(t) { self = .Array(v); return }
                case let t as [Key:Value].Type: if let v = try? c.decode(t) { self = .Object(v); return }
                default: break
                }
            }
        }
        self = JSON.Null
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        if self.isNull {
            try c.encodeNil()
            return
        }
        switch self {
        case .Bool(let v):      try c.encode(v)
        case .Number(let v):    try c.encode(v)
        case .String(let v):    try c.encode(v)
        case .Array(let v):     try c.encode(v)
        case .Object(let v):    try c.encode(v)
        default:
            break
        }
    }
}
