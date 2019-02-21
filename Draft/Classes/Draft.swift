import Foundation

public protocol Draft: CustomStringConvertible {
    associatedtype ResponseType
    
    var scheme: String { get }
    
    var host: String { get }
    
    var port: Int? { get }
    
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
        return "request to \(scheme)://\(host)\(path) with parameters \(parameters)"
    }
    
    var scheme: String { return "https" }
    
    var host: String { return "localhost" }
    
    var port: Int? { return nil }
    
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
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        components.path = path
        components.queryItems = parameters.map { (arg) -> URLQueryItem in
            URLQueryItem(name: arg.key, value: arg.value.description)
        }
        
        guard let url = components.url else {
            let request = Request<ResponseType>()
            request.error = RequestError.badUrl(description) // thoughts? better fail-over?
            return request
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpBody = body
        
        let request = Request<ResponseType>()
        request.run(request: urlRequest, in: session, with: convert)
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
        return JSON(dict: bodyDict).data
    }
    
    func convert(data: Data) throws -> ResponseType {
        guard let json = JSON(data: data) else {
            throw RequestError.badResponse(data)
        }
        return try convert(json: json)
    }
}

public extension JSONDraft where ResponseType == JSON {
    func convert(json: JSON) throws -> JSON {
        return json
    }
}
