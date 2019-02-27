import Foundation

public protocol Draft: CustomStringConvertible {
    associatedtype ResponseType
    
    var host: String { get }
    
    var path: String { get }
    
    var method: HTTPMethod { get }
    
    var parameters: HTTPParameters { get }
    
    var body: Data? { get }
    
    var headers: HTTPHeaders { get }
    
    var session: URLSession { get }
    
    func convert(data: Data) throws -> ResponseType
}

public extension Draft {
    var description: String {
        return "request to \(host)\(path) with parameters \(parameters)"
    }
    
    var host: String { return "localhost" }
    
    var path: String { return "/" }
    
    var method: HTTPMethod { return .get }
    
    var parameters: HTTPParameters { return [:] }
    
    var body: Data? { return nil }
    
    var headers: HTTPHeaders {
        return [
            "Content-Type": "application/json"
        ]
    }
    
    var session: URLSession { return .shared }
    
    func run() -> Request<ResponseType> {
        guard var components = URLComponents(string: host) else {
            return fail(error: RequestError.badUrl(description))
        }
        
        components.path = path
        components.queryItems = parameters.isEmpty ? nil : parameters.map { (arg) -> URLQueryItem in
            URLQueryItem(name: arg.key, value: arg.value.description)
        }
        
        guard let url = components.url else {
            return fail(error: .badUrl(description))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpBody = body
        
        let request = Request<ResponseType>()
        request.run(request: urlRequest, in: session, with: convert)
        return request
    }
    
    func fail<T>(error: RequestError) -> Request<T> {
        let request = Request<T>()
        request.error = error
        return request
    }
}

public extension Draft where ResponseType == Data {
    func convert(data: Data) -> Data { return data }
}

// MARK: - DecodableDraft

public protocol DecodableDraft: Draft {
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? { get }
}

public extension DecodableDraft where ResponseType: Decodable {
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? { return nil }
    
    func convert(data: Data) throws -> ResponseType {
        let decoder = JSONDecoder()
        if let strategy = dateDecodingStrategy {
            decoder.dateDecodingStrategy = strategy
        }
        return try decoder.decode(ResponseType.self, from: data)
    }
}

// MARK: - JSONDraft

public protocol JSONDraft: Draft {
    var bodyDict: [String: Any] { get }
    func convert(json: JSON) throws -> ResponseType
}

public extension JSONDraft {
    var bodyDict: [String: Any] { return [:] }
    
    var body: Data? {
        let json = JSON(dict: bodyDict)
        return json.data
    }
    
    func convert(data: Data) throws -> ResponseType {
        guard let json = JSON(data: data) else {
            throw RequestError.badResponse("Could not serialize into JSON")
        }
        return try convert(json: json)
    }
}

public extension JSONDraft where ResponseType == JSON {
    func convert(json: JSON) throws -> JSON {
        return json
    }
}
