import Foundation

public protocol Draft: CustomStringConvertible {
    associatedtype ResponseType
    
    var host: String { get }
    
    var route: String { get }
    
    var method: HTTPMethod { get }
    
    var parameters: HTTPParameters { get }
    
    var headers: HTTPHeaders { get }
    
    var session: URLSession { get }
    
    func convert(data: Data) throws -> ResponseType
}

public extension Draft {
    var description: String {
        return "request"
    }
    
    var host: String { return "http://localhost" }
    
    var route: String { return "/" }
    
    var method: HTTPMethod { return .get }
    
    var parameters: HTTPParameters { return [:] }
    
    var headers: HTTPHeaders { return [:] }
    
    var session: URLSession { return .shared }
    
    func run() -> Request<ResponseType> {
        guard var url = URL(string: host) else {
            let request = Request<ResponseType>()
            request.error = RequestError.badUrl(host)
            return request
        }
        
        for component in route.split(separator: "/", omittingEmptySubsequences: true) {
            url.appendPathComponent(String(component))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        
        let request = Request<ResponseType>()
        request.run(request: urlRequest, in: session, with: convert)
        return request
    }
}

public extension Draft where ResponseType == Data {
    func convert(data: Data) -> Data { return data }
}

// MARK: - DecodableDraft

public protocol DecodableDraft: Draft {}

public extension DecodableDraft where ResponseType: Decodable {
    func convert(data: Data) throws -> ResponseType {
        return try JSONDecoder().decode(ResponseType.self, from: data)
    }
}

// MARK: - JSONDraft

public protocol JSONDraft: Draft {
    func convert(json: JSON) throws -> ResponseType
}

public extension JSONDraft {
    func convert(data: Data) throws -> ResponseType {
        let json = JSON(data: data)
        return try convert(json: json)
    }
}

public extension JSONDraft where ResponseType == JSON {
    func convert(json: JSON) throws -> JSON {
        return json
    }
}
