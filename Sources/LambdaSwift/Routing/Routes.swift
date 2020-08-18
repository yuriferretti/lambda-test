import Foundation
import AWSLambdaEvents
import AWSLambdaRuntime
import NIO

struct Routes {
    private let pathSeparator = "/"
    
    var trieRouter = TriePathRouter(pathWildCard: ":")
    
    init(@RequestRouteBuilder routes: () -> [RequestRouteHandler]) {
        routes().forEach(trieRouter.addHandler)
    }
    
    func route(for request: APIGateway.V2.Request) -> RequestRouteHandler? {
        let http = request.context.http
        let path = http.path.split(separator: "/").map(String.init)
        let method = http.method
        return trieRouter.handler(at: path, for: method)
    }
}

fileprivate extension String {
    
    var isDynamicParameter: Bool {
        return starts(with: ":")
    }
}

@_functionBuilder
struct RequestRouteBuilder {
    
    static func buildBlock(_ handlers: RequestRouteHandler ...) -> [RequestRouteHandler] {
        return handlers
    }
}
