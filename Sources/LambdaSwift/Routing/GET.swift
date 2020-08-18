import AWSLambdaRuntime
import AWSLambdaEvents
import Foundation

struct GET: RequestRouteHandler {
    var pathComponents: [String]
    let method: HTTPMethod = .GET
    var handler: RequestHandler
    
    init(_ components: String..., handler: @escaping RequestHandler) {
        self.pathComponents = components
        self.handler = handler
    }
}
