import Foundation

public enum JSON {
    case null
    case object([String : JSON])
    case array([JSON])
    case bool(Bool)
    case string(String)
    case number(NSNumber)
    
    public subscript(index: String) -> JSON {
        get {
            guard case .object(let object) = self else { return .null }
            return object[index] ?? .null
        }
        set {
            set(json: newValue, at: index)
        }
    }
    
    public subscript(index: Int) -> JSON {
        get {
            guard case .array(let array) = self, index < array.count else { return .null }
            return array[index]
        }
        set {
            set(json: newValue, at: index)
        }
    }
    
    private mutating func set(json: JSON, at index: String) {
        guard case .object(var object) = self else { return }
        object[index] = json
        self = .object(object)
    }
    
    private mutating func set(json: JSON, at index: Int) {
        guard case .array(var array) = self, index < array.count else { return }
        array[index] = json
        self = .array(array)
    }
    
    public var object: [String : JSON]? {
        guard case .object(let object) = self else { return nil }
        return object
    }
    
    public var array: [JSON]? {
        guard case .array(let array) = self else { return nil }
        return array
    }
    
    public var bool: Bool? {
        guard case .bool(let bool) = self else { return nil }
        return bool
    }
    
    public var string: String? {
        guard case .string(let string) = self else { return nil }
        return string
    }
    
    public var number: NSNumber? {
        guard case .number(let number) = self else { return nil }
        return number
    }
    
    public var int: Int? {
        guard case .number(let number) = self else { return nil }
        return number as? Int
    }
    
    public var double: Double? {
        guard case .number(let number) = self else { return nil }
        return number as? Double
    }
    
    public var float: Float? {
        guard case .number(let number) = self else { return nil }
        return number as? Float
    }
    
    public init() {
        self = .object([:])
    }
    
    public init?(data: Data) {
        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }
        
        self = JSON.parse(jsonData: json)
    }
    
    public init(jsonString: String) {
        if let data = jsonString.data(using: .utf8) {
            self = JSON.parse(jsonData: data)
        } else {
            self = .null
        }
    }
    
    public init(dict: [String : Any]) {
        self = JSON.parse(jsonData: dict)
    }
    
    public init(array: [Any]) {
        self = JSON.parse(jsonData: array)
    }
    
    private static func parse(jsonData: Any) -> JSON {
        if let object = jsonData as? [String : Any] {
            let parsedObject = Dictionary(uniqueKeysWithValues: object.map { ($0, parse(jsonData: $1)) })
            return .object(parsedObject)
        }
        
        if let array = jsonData as? [Any] {
            let parsedArray = array.map { parse(jsonData: $0) }
            return .array(parsedArray)
        }
        
        if let bool = jsonData as? Bool {
            return .bool(bool)
        }
        
        if let string = jsonData as? String {
            return .string(string)
        }
        
        if let number = jsonData as? NSNumber {
            return .number(number)
        }
        
        return .null
    }
    
    public var jsonObject: Any {
        switch self {
        case .null:
            return [:]
        case .object(let object):
            return Dictionary(uniqueKeysWithValues: object.map { ($0, $1.jsonObject) })
        case .array(let array):
            return array.map { $0.jsonObject }
        case .bool(let bool):
            return bool
        case .string(let string):
            return string
        case .number(let number):
            return number
        }
    }
    
    public var jsonString: String? {
        guard let data = self.data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    public var data: Data? {
        guard let data = try? JSONSerialization.data(withJSONObject: jsonObject) else { return nil }
        return data
    }
}

extension JSON: Equatable {
    public static func == (lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null):
            return true
        case let (.object(lobj), .object(robj)) where lobj == robj:
            return true
        case let (.array(larr), .array(rarr)) where larr == rarr:
            return true
        case let (.bool(lbool), .bool(rbool)) where lbool == rbool:
            return true
        case let (.string(lstr), .string(rstr)) where lstr == rstr:
            return true
        case let (.number(lnum), .number(rnum)) where lnum == rnum:
            return true
        case (_, _):
            return false
        }
    }
}

extension JSON: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        guard
            let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
            let string = String(data: data, encoding: .utf8)
        else {
            return "Unable to serialize json"
        }
        
        return string
    }
    
    public var debugDescription: String {
        return description
    }
}
