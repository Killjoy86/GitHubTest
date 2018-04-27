//
//  ServerManager.swift
//  GitHubTest
//
//  Created by Roman Syrota on 01.04.2018.
//  Copyright © 2018 Roman Syrota. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ServerManager: NSObject {
    
    static let shared = ServerManager()

    var sessionManager: SessionManager!
    let baseURL = "https://api.github.com/users/"
    
    //MARK: - Requests
    func getUser(name: String?,
                 success: @escaping (_ user: User?, _ message: String?) -> (),
                 failure: @escaping (_ statusCode: Int?, _ error: Error?) -> ()) {
        sessionManager = SessionManager(configuration: .default)
        
        guard var name = name else { return }
        if name.contains(" ") {
            name = name.components(separatedBy: " ").joined()
        }
        
        guard let url = URL(string: baseURL + name) else { return }
        sessionManager.request(url, method: .get, parameters: nil).responseJSON { (response) in
            
            switch response.result {
            case .success:
                let responseJSON = JSON(response.data!)
                
                if let message = responseJSON["message"].string {
                    success(nil, message)
                } else {
                    let user = User(responseJSON: responseJSON)
                    success(user, nil)
                }
            case .failure(let error):
                let statusCode = response.response?.statusCode
                failure(statusCode, error)
            }
        }
        
    }
    
    func getReposBy(user: User,
                    success: @escaping (_ reposArray: [Repository]) -> (),
                    failure: @escaping (_ statusCode: Int?, _ error: Error?) -> ()) {
        sessionManager = SessionManager(configuration: .default)
        var reposArray = [Repository]()
        if let url = user.reposURL {
            sessionManager.request(url, method: .get, parameters: nil).responseJSON { (response) in
                switch response.result {
                case .success:
                    if let responseReposArray = JSON(response.data!).array {
                        for repoJSON in responseReposArray {
                            let repository = Repository(responseJSON: repoJSON)
                            reposArray.append(repository)
                        }
                    }
                    success(reposArray)
                case .failure(let error):
                    let statusCode = response.response?.statusCode
                    failure(statusCode, error)
                }
            }
        } else {
            success(reposArray)
        }
    }
}
