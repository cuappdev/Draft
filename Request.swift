import Foundation

public class Request<Response> {
    var task: URLSessionDataTask?
    var response: Response?
    var error: Error?
    
    private var onSuccess: ((Response) -> Void)? = nil
    private var onFailure: ((Error) -> Void)? = nil
    
    public func success(handler: @escaping (Response) -> Void) -> Self {
        self.onSuccess = handler
        
        if let response = response {
            DispatchQueue.main.async {
                handler(response)
            }
        }
        
        return self
    }
    
    @discardableResult
    public func failure(handler: @escaping (Error) -> Void) -> Self {
        self.onFailure = handler
        
        if let error = error {
            DispatchQueue.main.async {
                handler(error)
            }
        }
        
        return self
    }
    
    public func cancel() {
        task?.cancel()
    }
    
    func run(request: URLRequest, in session: URLSession, with handler: @escaping (Data) throws -> Response) {
        task = session.dataTask(with: request) { (data, response, error) in
            do {
                guard let data = data else {
                    self.onFailure?(error ?? RequestError.unknown)
                    return
                }
                
                let response = try handler(data)
                DispatchQueue.main.async {
                    self.onSuccess?(response)
                }
            } catch {
                DispatchQueue.main.async {
                    self.onFailure?(error)
                }
            }
        }
        
        task?.resume()
    }
    
}
