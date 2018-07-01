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
        case notIterable(JSON.ContentType)
        case notSubscriptable(JSON.ContentType)
        case indexOutOfRange(JSON.Index)
        case keyNonexistent(JSON.Key)
        case nsError(NSError)
    }
    public typealias Key    = String
    public typealias Value  = JSON
    public typealias Index  = Int
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
    public func toString(depth d:Int, separator s:String, terminator t:String, sortedKey:Bool=false)->String {
        let i = Swift.String(repeating:s, count:d)
        let g = s == "" ? "" : " "
        switch self {
        case .Error(let m):     return ".Error(\"\(m)\")"
        case .Null:             return "null"
        case .Bool(let v):      return v.description
        case .Number(let v):    return v.description
        case .String(let v):    return v.debugDescription
        case .Array(let a):
            return "[" + t
                + a.map{ $0.toString(depth:d+1, separator:s, terminator:t, sortedKey:sortedKey) }
                    .map{ i + s + $0 }.joined(separator:","+t) + t
                + i + "]" + (d == 0 ? t : "")
        case .Object(let o):
            let a = sortedKey ? o.map{ $0 }.sorted{ $0.0 < $1.0 } : o.map{ $0 }
            return "{" + t
                + a.map { $0.debugDescription + g + ":" + g + $1.toString(depth:d+1, separator:s, terminator:t, sortedKey:sortedKey) }
                    .map{ i + s + $0 }.joined(separator:"," + t) + t
                + i + "}" + (d == 0 ? t : "")
        }
    }
    public func toString(space:Int=0)->String {
        return space == 0
            ? toString(depth:0, separator:"", terminator:"")
            : toString(depth:0, separator:Swift.String(repeating:" ", count:space), terminator:"\n", sortedKey:true)
    }
    public var description:String {
        return self.toString()
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
        return try! JSONSerialization.jsonObject(with:self.data, options:[.allowFragments])
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
    public var isIterable:Bool {
        return type == .array || type == .object
    }
}
extension JSON {
    public subscript(_ idx:Index)->JSON {
        get {
            switch self {
            case .Error(_):
                return self
            case .Array(let a):
                guard idx < a.count else { return .Error(.indexOutOfRange(idx)) }
                return a[idx]
            default:
                return .Error(.notSubscriptable(self.type))
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
            case .Error(_):
                return self
            case .Object(let o):
                return o[key] ?? .Error(.keyNonexistent(key))
            default:
                return .Error(.notSubscriptable(self.type))
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
        case None
        case Index(Int)
        case Key(String)
        public var index:Int?  { switch self { case .Index(let v): return v default: return nil } }
        public var key:String? { switch self { case .Key(let v):   return v default: return nil } }
    }
    public typealias Element = (key:IteratorKey,value:JSON)  // for Sequence conformance
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
    public func walk<R>(depth:Int=0, collect:(JSON, [(IteratorKey, R)], Int)->R, visit:(JSON)->R)->R {
        return collect(self, self.map {
            let value = $0.1.isIterable ? $0.1.walk(depth:depth+1, collect:collect, visit:visit)
            : visit($0.1)
            return ($0.0, value)
        }, depth)
    }
    public func walk(depth:Int=0, visit:(JSON)->JSON)->JSON {
        return self.walk(depth:depth, collect:{ node,pairs,depth in
            switch node.type {
            case .array:
                return .Array(pairs.map{ $0.1 })
            case .object:
                var o = [Key:Value]()
                pairs.forEach{ o[$0.0.key!] = $0.1 }
                return .Object(o)
            default:
                return .Error(.notIterable(node.type))
            }
        }, visit:visit)
    }
    public func walk(depth:Int=0, collect:(JSON, [Element], Int)->JSON)->JSON {
        return self.walk(depth:depth, collect:collect, visit:{ $0 })
    }
    public func pick(picker:(JSON)->Bool)->JSON {
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
extension JSON.JSONError : CustomStringConvertible {
    public enum ErrorType {
        case notAJSONObject, notIterable, notSubscriptable, indexOutOfRange, keyNonexistent, nsError
    }
    public var type:ErrorType {
        switch self {
        case .notAJSONObject:       return .notAJSONObject
        case .notIterable:          return .notIterable
        case .notSubscriptable(_):  return .notSubscriptable
        case .indexOutOfRange(_):   return .indexOutOfRange
        case .keyNonexistent(_):    return .keyNonexistent
        case .nsError(_):           return .nsError
        }
    }
    public var nsError:NSError? { switch self { case .nsError(let v) : return v default : return nil } }
    public var description:String {
        switch self {
        case .notAJSONObject:           return "not an jsonObject"
        case .notIterable(let t):       return "\(t) is not iterable"
        case .notSubscriptable(let t):  return "\(t) cannot be subscripted"
        case .indexOutOfRange(let i):   return "index \(i) is out of range"
        case .keyNonexistent(let k):    return "key \"\(k)\" does not exist"
        case .nsError(let e):           return "\(e)"
        }
    }
}
