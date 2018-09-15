import UIKit
import Draft

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GetEateries().run()
            .success { (response: Data) in
                print("Eateries data acquired")
            }
            .failure { (error: Error) in
                print("error getting eateries: \(error.localizedDescription)")
            }
        
        GetJSONQuote().run()
            .success { (response: String) in
                print("JSON Quote: \(response)")
            }
            .failure { (error: Error) in
                print("Error getting JSON quote: \(error)")
            }
        
        GetDecodableQuote().run()
            .success { (response: APIResponse<QuotesContents>) in
                guard let quote = response.contents.quotes.first?.quote else {
                    return
                }
                
                print("DecodableQuote: \(quote)")
            }
            .failure { (error: Error) in
                print("error getting quote: \(error.localizedDescription)")
        }
        
    }
}

// Plain Data

struct GetEateries: Draft {
    typealias ResponseType = Data
    
    let host = "https://now.dining.cornell.edu"
    let route = "/api/1.0/dining/eateries.json"
}

// JSON

struct GetJSONQuote: JSONDraft {
    typealias ResponseType = String
    
    let host = "https://quotes.rest"
    let route = "/qod"
    
    func convert(json: JSON) throws -> String {
        guard let quote = json["contents"]["quotes"].array?.first?["quote"].string else {
            throw RequestError.badResponse(json)
        }
        
        return quote
    }
}

// Codable

struct GetDecodableQuote: DecodableDraft {    
    typealias ResponseType = APIResponse<QuotesContents>
    
    let host = "https://quotes.rest"
    let route = "/qod"
}

struct APIResponse<T: Codable>: Codable {
    let success: Success
    let contents: T
    
    struct Success: Codable {
        let total: Int
    }
}

struct QuotesContents: Codable {
    let quotes: [Quote]
    
    struct Quote: Codable {
        let quote: String
    }
}



