import AWSLambdaEvents
import AWSLambdaRuntime
import Foundation
import NIO

protocol RequestRouteHandler {
    typealias Request = APIGateway.V2.Request
    typealias Response = APIGateway.V2.Response
    typealias RequestHandler = (Request, Lambda.Context) throws -> EventLoopFuture<Response>
    
    var pathComponents: [String] { get }
    var method: HTTPMethod { get }
    var handler: RequestHandler { get }
}
