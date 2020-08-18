import AWSDynamoDB
import Foundation
import NIO

protocol DynamoEntity {
    static var primaryKey: String { get }
    static var sortKey: String? { get }
}

extension DynamoEntity {
    static var sortKey: String? { nil }
}

struct DynamoDBRepository<Entity> where Entity: Codable & DynamoEntity {
    private let dynamo: DynamoDB
    private let tableName: String
    
    init(dynamo: DynamoDB, tableName: String) {
        self.dynamo = dynamo
        self.tableName = tableName
    }
    
    func listAllEntities() -> EventLoopFuture<[Entity]> {
        let input = DynamoDB.ScanInput(tableName: tableName)
        return dynamo.scan(input, type: Entity.self).map{ $0.items ?? [] }
    }
    
    func findEntity(key: String) -> EventLoopFuture<Entity?> {
        let key = Self.getItemKey(key)
        let input = DynamoDB.GetItemInput(key: key , tableName: tableName)
        return dynamo.getItem(input, type: Entity.self).map(\.item)
    }
    
    func createEntity(_ entity: Entity) -> EventLoopFuture<Void> {
        let input = DynamoDB.PutItemCodableInput(item: entity, tableName: tableName)
        return dynamo.putItem(input).mapToVoid()
    }
    
    func updateEntity(_ entity: Entity) -> EventLoopFuture<Void> {
        let input = DynamoDB.UpdateItemCodableInput(
            key: [Entity.primaryKey] ,
            tableName: tableName, updateItem: entity
        )
        return dynamo.updateItem(input).mapToVoid()
    }
    
    private static func getItemKey(_ key: String) -> [String: DynamoDB.AttributeValue] {
        return [ Entity.primaryKey: .s(key) ]
    }
}

private extension EventLoopFuture {
    
    func mapToVoid() -> EventLoopFuture<Void> {
        return self.map { _ in () }
    }
}

