import Foundation

struct APIError: Error {
    var description: String
    
    static let decodingError = APIError(description: "Decoding error")
    static let requestError = APIError(description: "Request error")
    static let notFound = APIError(description: "Not found")
    static let duplicatedRouteError = APIError(description: "Found duplicated routes")
    
    private init(description: String) { self.description = description }
}
