import Foundation

struct Person: Codable {
    var cpf: String
    var firstName: String
    var lastName: String
}

extension Person: DynamoEntity {
    static var primaryKey: String { "cpf" }
}

struct Greeting: Codable {
    var greeting: String
}
