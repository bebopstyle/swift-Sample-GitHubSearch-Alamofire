//
//  GitHub.swift
//  GithubSearch
//
//  Created by 大庭 芳史(Oba Yoshifumi) on 2016/02/18.
//  Copyright © 2016年 大庭 芳史(Oba Yoshifumi). All rights reserved.
//

import Foundation
import Alamofire

public typealias JSONObject = [String: AnyObject]

public enum HTTPMethod {
    case Get
}

public protocol JSONDecodable {
    init(JSON: JSONObject) throws
}

public protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters { get }
    typealias ResponseType: JSONDecodable
}

public struct Parameters: DictionaryLiteralConvertible {
    public private(set) var dictionary: [String: AnyObject] = [:]
    public typealias Key = String
    public typealias Value = AnyObject?
    /**
    Initialized from dictionary literals
    */
    public init(dictionaryLiteral elements: (Parameters.Key, Parameters.Value)...) {
        for case let (key, value?) in elements {
            dictionary[key] = value
        }
    }
    
    
}

public class GitHubAPI {
    private let baseUrl = "https://api.github.com/"
    
    private let HTTPSessionManager: Manager = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = [
            "Accept":"application/vnd.github.v3+json"
        ]
        let manager = Alamofire.Manager(configuration: configuration)
        return manager
    } ()
    
    public init() {
        
    }
    
    public func request<Endpoint: APIEndpoint>(endpoint: Endpoint, handler: (task: NSURLSessionDataTask, response: Endpoint.Type?, error: ErrorType?) -> Void) {

        switch endpoint.method {
        case .Get:
                HTTPSessionManager
                    .request(.GET, baseUrl)
                    .responseJSON { request in
                        if request.result.isSuccess {
                            
                        } else {
                            
                        }
                        
                        
            }
        }
    }
}

public struct SearchRepositories: APIEndpoint {
    public var path = "search/repositories"
    public var method = HTTPMethod.Get
    public var parameters: Parameters {
        return [
            "q" : query,
            "page" : page,
        ]
    }
    public typealias ResponseType = SearchResult<Repository>
    
    public let query: String
    public let page: Int
    
    public init(query: String, page: Int) {
        self.query = query
        self.page = page
    }
}

public struct SearchResult<ItemType: JSONDecodable>: JSONDecodable {
    public let totalCount: Int
    public let incompleteResults: Bool
    public let items: [ItemType]
    
    public init(JSON: JSONObject) throws {
        self.totalCount = try getValue(JSON, key: "total_count")
        self.incompleteResults = try getValue(JSON, key: "incomplete_results")
        self.items = try (getValue(JSON, key: "items") as [JSONObject]).map { return try ItemType(JSON: $0) }
        
    }
}

public enum JSONDecodeError: ErrorType {
    case MissingRequiredKey(String)
    case UnexpectedType(key: String, expected: Any.Type, actual: Any.Type)
}

private func getValue<T>(JSON: JSONObject, key: String) throws -> T {
    guard let value = JSON[key] else {
        throw JSONDecodeError.MissingRequiredKey(key)
    }
    guard let typedValue = value as? T else {
        throw JSONDecodeError.UnexpectedType(key: key, expected: T.self, actual: value.dynamicType)
    }
    return typedValue
}
