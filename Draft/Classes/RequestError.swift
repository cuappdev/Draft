import Foundation

public enum RequestError: Error {
    case badUrl(String)
    case badResponse(Any)
    case unknown
}
