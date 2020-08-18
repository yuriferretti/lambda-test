//
//  File.swift
//  
//
//  Created by Yuri Ferretti on 16/08/20.
//

import AWSLambdaEvents
import AWSLambdaRuntime
import Foundation
import NIO

extension EventLoopFuture where Value == APIGateway.V2.Response {
    
    func catchErrorAndReturn(_ error: @escaping @autoclosure () -> Error, context: Lambda.Context) -> EventLoopFuture<Value> {
        return self.flatMapError { e in
            context.logger.error("error found \(String(describing: e))")
            let response = APIGateway.V2.Response(with: error(), statusCode: .notFound)
            return context.eventLoop.makeSucceededFuture(response)
        }
    }
}
