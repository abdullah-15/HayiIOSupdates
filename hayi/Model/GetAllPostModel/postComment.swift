//
//  postComment.swift
//  hayi-ios2
//
//  Created by Mohsin on 08/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
import SwiftyJSON
class postComment : Codable {
    
    
    var postCommentsId: Int?
    var comment: String?
    var commentHtml : String?
    var postId :Int?
    var commentByUserId : Int?
    //"user": null
    
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    /// Initiates the instance based on the JSON that was passed.
    ///
    /// - parameter json: JSON object from SwiftyJSON.
    public required init(json: JSON) {
        
        postCommentsId = (json["postCommentsId"].int )
        comment = (json["comment"].string)
        postId = (json["postId"].int )
        commentHtml = (json["commentHtml"].string)
        commentByUserId = (json["commentByUserId"].int )
    

    }
    
}
