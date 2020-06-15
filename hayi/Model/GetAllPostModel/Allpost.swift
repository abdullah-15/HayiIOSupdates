//
//  Allpost.swift
//  hayi-ios2
//
//  Created by Mohsin on 08/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
import SwiftyJSON

class Allpost : Codable {
    
    var postId : Int?
    var postTypeId : Int?
    var postCategoriesId : Int?
    var postMessage  : String?
    var created  : String?
    var lastActivity: String?
    var selfLiked: Int?
    var commentCount:Int?
    var likeCount: Int?
    var content: [postMediaContents]?
    var CreatedByUser : byUser
    var neighbourhoodsId : Int?
    
    

    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    /// Initiates the instance based on the JSON that was passed.
    ///
    /// - parameter json: JSON object from SwiftyJSON.
    public required init(json: JSON) {
        
          postId = (json["postId"].int)
         postTypeId =  (json["postTypeId"].int)
         postCategoriesId = (json["postCategoriesId"].int)
         postMessage = (json["postMessage"].string )
         postCategoriesId = (json["postCategoriesId"].int )
         lastActivity = (json["lastActivity"].string )
         selfLiked = (json["selfLiked"].int)
         commentCount = (json["commentCount"].int )
         likeCount = (json["likeCount"].int )
         created = (json["created"].string )
         let detail = json["postMediaContents"].array
         
         var array = [postMediaContents]()
         for a in detail!
         {
             let obj = postMediaContents(json: a)
             array.append(obj)
             
         }
         self.content = array
         
         
         let byUserdetail = json["byUser"]
         let obj = byUser(json: byUserdetail)
        
         self.CreatedByUser = obj

    }
    
}
