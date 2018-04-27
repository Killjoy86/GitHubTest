//
//  Repository.swift
//  GitHubTest
//
//  Created by Roman Syrota on 01.04.2018.
//  Copyright © 2018 Roman Syrota. All rights reserved.
//

import UIKit
import SwiftyJSON

class Repository {
    var identifier: Int!
    var name: String!
    var stargazers: Int!
    
    init(responseJSON: JSON) {
        if let identifier = responseJSON["id"].int {
            self.identifier = Int(identifier)
            if let name = responseJSON["name"].string {
                self.name = name
                if let stargazers = responseJSON["stargazers_count"].int {
                    self.stargazers = stargazers
                }
            }
        }
    }
}
