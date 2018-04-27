//
//  User.swift
//  GitHubTest
//
//  Created by Roman Syrota on 01.04.2018.
//  Copyright © 2018 Roman Syrota. All rights reserved.
//

import UIKit
import SwiftyJSON

class User {
    var name: String!
    var login: String!
    var reposURL: URL!
    var reposArray: [Repository]?
    
    init(responseJSON: JSON) {
        if let login = responseJSON["login"].string {
            self.login = login
            if let name = responseJSON["name"].string {
                self.name = name
                if let reposURL = responseJSON["repos_url"].string {
                    self.reposURL = URL(string: reposURL)!
                }
            }
        }
    }
}
