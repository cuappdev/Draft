import Foundation

public enum RequestError: Error, LocalizedError {
    case badUrl(String)
    case badResponse(String)
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .badUrl(let message):
            return "Bad URL: \(message)"
        case .badResponse(let message):
            return "Bad response: \(message)"
        case .unknown:
            return "Unknown error"
        }
    }
}
