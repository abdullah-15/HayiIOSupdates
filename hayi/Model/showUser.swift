//
//  showUser.swift
//  hayi-ios2
//
//  Created by Mohsin on 17/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
import SwiftyJSON
class showUser : Codable {
    var usersId: Int?
    var fullName: String?
    var profileImage: String?
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    /// Initiates the instance based on the JSON that was passed.
    ///
    /// - parameter json: JSON object from SwiftyJSON.
    public required init(json: JSON) {
        
        usersId = (json["usersId"].int )
        fullName = (json["fullName"].string)
        profileImage = (json["profileImage"].string )
        
    }
   
}

