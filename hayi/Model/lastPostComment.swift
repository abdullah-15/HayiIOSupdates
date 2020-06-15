//
//  lastPostComment.swift
//  hayi-ios2
//
//  Created by Mohsin on 01/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
import SwiftyJSON

class lastPostComment: Codable {
    var postCommentsId : Int?
    var comment : String?
    var commentByUserId : Int?
    var fullName : String?
    var profileImage : String?
    
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    /// Initiates the instance based on the JSON that was passed.
    ///
    /// - parameter json: JSON object from SwiftyJSON.
    public required init(json: JSON) {
        
        postCommentsId = (json["postCommentsId"].int)
        comment = (json["comment"].string)
        commentByUserId = (json["commentByUserId"].int)
        fullName = (json["fullName"].string)
        profileImage = (json["profileImage"].string)
        
    }
}
