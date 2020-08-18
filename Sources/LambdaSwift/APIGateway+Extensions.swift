import AWSLambdaEvents
import Foundation

extension APIGateway.V2.Request {
    
    private static let jsonDecoder: JSONDecoder = {
        return JSONDecoder()
    }()
    
    func decode<D: Decodable>() throws -> D {
        guard let jsonData = body?.data(using: .utf8) else {
            throw APIError.requestError
        }
        let object = try Self.jsonDecoder.decode(D.self, from: jsonData)
        return object
    }
}

extension APIGateway.V2.Response {
    
    private static let jsonEncoder: JSONEncoder = {
        return JSONEncoder()
    }()
    
    public static let defaultHeaders = [
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "OPTIONS,GET,POST,PUT,DELETE",
        "Access-Control-Allow-Credentials": "true",
    ]
    
    public init(with error: Error, statusCode: AWSLambdaEvents.HTTPResponseStatus) {
        self.init(
            statusCode: statusCode,
            headers: Self.defaultHeaders,
            multiValueHeaders: nil,
            body: "{\"error\":\"\(String(describing: error))\"}",
            isBase64Encoded: false
        )
    }
    
    public init<Out: Encodable>(with object: Out, statusCode: AWSLambdaEvents.HTTPResponseStatus) {
        var body: String = "{}"
        if let data = try? Self.jsonEncoder.encode(object) {
            body = String(data: data, encoding: .utf8) ?? body
        }
        self.init(
            statusCode: statusCode,
            headers: Self.defaultHeaders,
            multiValueHeaders: nil,
            body: body,
            isBase64Encoded: false
        )
    }
}

struct EmptyResponse: Encodable {}
