//
//  postMediaContents.swift
//  hayi-ios2
//
//  Created by Mohsin on 01/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
import SwiftyJSON
class postMediaContents: Codable {
    var postId: Int?
    var path : String?
    var createdAt : String?
    
    
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    /// Initiates the instance based on the JSON that was passed.
    ///
    /// - parameter json: JSON object from SwiftyJSON.
    public required init(json: JSON) {
        
        postId = (json["usersId"].int )
        path = (json["path"].string)
        createdAt = (json["createdAt"].string )
        
}
}
