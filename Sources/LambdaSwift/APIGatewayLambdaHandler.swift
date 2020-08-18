import AWSLambdaEvents
import AWSLambdaRuntime
import Foundation
import NIO

protocol APIGatewayLambdaHandler: EventLoopLambdaHandler
where Out == APIGateway.V2.Response,
      In == APIGateway.V2.Request
{

    func routes(in context: Lambda.Context) -> Routes
    func handler(for request: APIGateway.V2.Request, in context: Lambda.Context) throws -> RequestRouteHandler
}

extension APIGatewayLambdaHandler {
    
    func handler(for request: APIGateway.V2.Request, in context: Lambda.Context) throws -> RequestRouteHandler {
        let routes = self.routes(in: context)
        guard let handler = routes.route(for: request) else {
            context.logger.error("Could not find handler for request \(request.context.http.method) \(request.context.http.path)")
            throw APIError.notFound
        }
        
        context.logger.info("found router \(handler.method) \(handler.pathComponents)")
        
        return handler
    }
    
    func handle(context: Lambda.Context, event: APIGateway.V2.Request) -> EventLoopFuture<APIGateway.V2.Response> {
        do {
            return try handler(for: event, in: context).handler(event, context)
                .catchErrorAndReturn(APIError.notFound, context: context)
            
        } catch {
            context.logger.critical("handle method throw error")
            let response = APIGateway.V2.Response(with: APIError.notFound, statusCode: .notFound)
            return context.eventLoop.makeSucceededFuture(response)
        }
    }
}
