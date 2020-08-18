import AWSLambdaRuntime
import AWSLambdaEvents
import Foundation
import NIO

struct POST: RequestRouteHandler {
    var pathComponents: [String]
    let method: HTTPMethod = .POST
    var handler: RequestHandler
    
    private init(_ components: [String], handler: @escaping RequestHandler) {
        self.pathComponents = components
        self.handler = handler
    }
}

extension POST {
    
    init(_ components: String..., handler: @escaping RequestHandler) {
        self.init(components, handler: handler)
    }
    
    init<Entity: Decodable>(
        _ pathComponents: String...,
        parsing: Entity.Type,
        handler: @escaping (Request, Lambda.Context, Entity) throws -> EventLoopFuture<Response>
    ) {
        self.init(pathComponents) { request, context in
            let entity: Entity = try request.decode()
            return try handler(request, context, entity)
        }
    }
}
