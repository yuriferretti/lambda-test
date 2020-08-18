import AWSLambdaEvents
import Foundation

class TriePathRouter {
    private let pathWildCard: String
    private let root = TrieNode()
    
    init(pathWildCard: String) {
        self.pathWildCard = pathWildCard
    }
    
    private class TrieNode {
        private(set) var children: [String: TrieNode] = [:]
        var handlers: [String: RequestRouteHandler] = [:]
        
        init() {}
        
        func getChildNodeOrCreate(key: String) -> TrieNode {
            if let node = children[key] {
                return node
            }
            
            let newNode = TrieNode()
            children[key] = newNode
            return newNode
        }
    }
    
    func addHandler(_ handler: RequestRouteHandler) {
        let node = handler.pathComponents.reduce(root) {
            $0.getChildNodeOrCreate(key: $1)
        }
        node.handlers[handler.method.rawValue] = handler
    }
    
    func handler(at path: [String], for method: HTTPMethod) -> RequestRouteHandler? {
        var currentNode = root
        
        for pathComponent in path {
            if let newNode = currentNode.children[pathComponent] {
                currentNode = newNode
            } else if let newNode = currentNode.children[pathWildCard] {
                currentNode = newNode
            } else {
                return nil
            }
        }
        
        return currentNode.handlers[method.rawValue]
    }
}
