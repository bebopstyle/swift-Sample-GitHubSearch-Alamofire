//
//  SearchRepositoriesManager.swift
//  GithubSearch
//
//  Created by 大庭 芳史(Oba Yoshifumi) on 2016/02/26.
//  Copyright © 2016年 大庭 芳史(Oba Yoshifumi). All rights reserved.
//

import Foundation

class SearchRepositoriesManager {
    
    let github: GitHubAPI
    let query: String
    
    var networking: Bool = false
    
    var results: [Repository] = []
    var completed: Bool = false
    var page: Int = 1
    
    init?(github: GitHubAPI, query: String) {
        self.github = github
        self.query = query
        if query.characters.isEmpty {
            return nil
        }
    }
    
    func search(reload: Bool, completion: (error: ErrorType?) -> Void) -> Bool {
        if completed || networking {
            return false
        }
        networking = true
        github.request(GitHubAPI.
    }
}