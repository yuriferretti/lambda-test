import AsyncHTTPClient
import AWSLambdaEvents
import AWSLambdaRuntime
import AWSDynamoDB
import Foundation
import NIO

struct PersonLambdaHandler: APIGatewayLambdaHandler {
    typealias In = APIGateway.V2.Request
    typealias Out = APIGateway.V2.Response
    
    private let dynamo: AWSDynamoDB.DynamoDB
    private let repository: DynamoDBRepository<Person>
    private let httpClient: HTTPClient
    private let logger: Logger
    
    init(context: Lambda.InitializationContext) {
        self.logger = context.logger
        
        let timeout = HTTPClient.Configuration.Timeout(
            connect: .seconds(30),
            read: .seconds(30)
        )
        httpClient = HTTPClient(
            eventLoopGroupProvider: .shared(context.eventLoop),
            configuration: HTTPClient.Configuration(timeout: timeout)
        )
        
        let tableName = Lambda.env("PERSON_TABLE_NAME") ?? ""
        logger.log(level: .info, "table name: \(tableName)")
        
        let region = Lambda.env("AWS_REGION").map(Region.init) ?? .useast1
        logger.log(level: .info, "region: \(region)")
        
        let client = AWSClient(httpClientProvider: .shared(httpClient))
        
        dynamo = AWSDynamoDB.DynamoDB(client: client, region: region)
        repository = DynamoDBRepository(dynamo: dynamo, tableName: tableName)
    }
    
    func routes(in context: Lambda.Context) -> Routes {
        context.logger.info("Will get available route")
        return Routes {
            GET("person", "list", handler: handleList)
            GET("person", "cpf", handler: handleGetByCpf)
            POST("person", "save", parsing: Person.self, handler: handleSave)
        }
    }
    
    private func handleList(_ request: In, context: Lambda.Context) -> EventLoopFuture<Out> {
        return repository.listAllEntities()
            .map { items in
                APIGateway.V2.Response(with: items, statusCode: .ok)
            }
            .catchErrorAndReturn(APIError.notFound, context: context)
    }
    
    private func handleGetByCpf(_ request: In, context: Lambda.Context) -> EventLoopFuture<Out> {
        guard let cpf = request.pathParameters?["cpf"] else {
            let response = APIGateway.V2.Response(with: APIError.requestError, statusCode: .badRequest)
            context.logger.error("could not find request param \(request.pathParameters ?? [:])")
            return context.eventLoop.makeSucceededFuture(response)
        }
        return repository.findEntity(key: cpf).map { person in
            return APIGateway.V2.Response(with: person, statusCode: .ok)
        }
        .catchErrorAndReturn(APIError.notFound, context: context)
    }
    
    private func handleSave(_ request: In, context: Lambda.Context, person: Person) -> EventLoopFuture<Out> {
        return repository.createEntity(person)
            .map { APIGateway.V2.Response(statusCode: .ok) }
            .catchErrorAndReturn(APIError.requestError, context: context)
    }
}
