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
    case CannotParseURL(key: String, value: String)
    case CannotParseDate(key: String, value: String)
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

private func getOptionalValue<T>(JSON: JSONObject, key: String) throws -> T? {
    guard let value = JSON[key] else {
        return nil
    }
    if value is NSNull {
        return nil
    }
    guard let typedValue = value as? T else {
        throw JSONDecodeError.UnexpectedType(key: key, expected: T.self, actual: value.dynamicType)
    }
    return typedValue
}

private func getURL(JSON: JSONObject, key: String) throws -> NSURL {
    let URLString: String = try getValue(JSON, key: key)
    guard let URL = NSURL(string: URLString) else {
        throw JSONDecodeError.CannotParseURL(key: key, value: URLString)
    }
    return URL
}

private func getOptionalURL(JSON: JSONObject, key: String) throws -> NSURL? {
    guard let URLString: String = try getOptionalValue(JSON, key: key) else { return nil }
    guard let URL = NSURL(string: URLString) else {
        throw JSONDecodeError.CannotParseURL(key: key, value: URLString)
    }
    return URL
}

private func getDate(JSON: JSONObject, key: String) throws -> NSDate {
    let dateString: String = try getValue(JSON, key: key)
    guard let date = dateFormatter.dateFromString(dateString) else {
        throw JSONDecodeError.CannotParseDate(key: key, value: dateString)
    }
    return date
}

private func getOptionalDate(JSON: JSONObject, key: String) throws -> NSDate? {
    guard let dateString: String = try getOptionalValue(JSON, key: key) else { return nil }
    guard let date = dateFormatter.dateFromString(dateString) else {
        throw JSONDecodeError.CannotParseDate(key: key, value: dateString)
    }
    return date
}

private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    return formatter
}()

public struct Repository: JSONDecodable {
    public let id: Int
    public let name: String
    public let fullName: String
    public let isPrivate: Bool
    public let HTMLURL: NSURL
    public let description: String?
    public let fork: Bool
    public let URL: NSURL
    public let createdAt: NSDate
    public let updatedAt: NSDate
    public let pushedAt: NSDate?
    public let homepage: String?
    public let size: Int
    public let stargazersCount: Int
    public let watchersCount: Int
    public let language: String?
    public let forksCount: Int
    public let openIssuesCount: Int
    public let masterBranch: String?
    public let defaultBranch: String
    public let score: Double
    public let owner: User
    
    public init(JSON: JSONObject) throws {
        self.id = try getValue(JSON, key: "id")
        self.name = try getValue(JSON, key: "name")
        self.fullName = try getValue(JSON, key: "full_name")
        self.isPrivate = try getValue(JSON, key: "private")
        self.HTMLURL = try getValue(JSON, key: "html_url")
        self.description = try getOptionalValue(JSON, key: "description")
        self.fork = try getValue(JSON, key: "fork")
        self.URL = try getURL(JSON, key: "url")
        self.createdAt = try getDate(JSON, key: "created_at")
        self.updatedAt = try getDate(JSON, key: "updated_at")
        self.pushedAt = try getOptionalDate(JSON, key: "pushed_at")
        self.homepage = try getOptionalValue(JSON, key: "homepage")
        self.size = try getValue(JSON, key: "size")
        self.stargazersCount = try getValue(JSON, key: "stargazers_count")
        self.watchersCount = try getValue(JSON, key: "watchers_count")
        self.language = try getOptionalValue(JSON, key: "language")
        self.forksCount = try getValue(JSON, key: "forks_count")
        self.openIssuesCount = try getValue(JSON, key: "open_issues_count")
        self.masterBranch = try getOptionalValue(JSON, key: "master_branch")
        self.defaultBranch = try getValue(JSON, key: "default_branch")
        self.score = try getValue(JSON, key: "score")
        self.owner = try User(JSON: getValue(JSON, key: "owner") as JSONObject)
    }
}

public struct User: JSONDecodable {
    public let login: String
    public let id: Int
    public let avatarURL: NSURL
    public let gravatarID: String
    public let URL: NSURL
    public let receivedEventsURL: NSURL
    public let type: String
    
    public init(JSON: JSONObject) throws {
        self.login = try getValue(JSON, key: "login")
        self.id = try getValue(JSON, key: "id")
        self.avatarURL = try getURL(JSON, key: "avatar_url")
        self.gravatarID = try getValue(JSON, key: "gravatar_id")
        self.URL = try getURL(JSON, key: "url")
        self.receivedEventsURL = try getURL(JSON, key: "received_events_url")
        self.type = try getValue(JSON, key: "type")
    }
}