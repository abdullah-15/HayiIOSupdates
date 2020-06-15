//
//  AllPostComments.swift
//  hayi
//
//  Created by MacBook Pro on 02/11/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
import SwiftyJSON

class AllPostComments : Codable {
    
    var postCommentsId: Int?
      var comment: String?
      var profileImage : String?
      var fullName :String?
      var commentByUserId : Int?
    var createdAt: String?
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
          fullName = (json["fullName"].string )
          profileImage = (json["profileImage"].string)
          commentByUserId = (json["commentByUserId"].int )
        createdAt = (json["createdAt"].string )


      }
    
    init( postCommentsId: Int?,comment: String?,profileImage : String?,fullName :String?,commentByUserId : Int?) {
        
        self.postCommentsId =  postCommentsId
        self.comment = comment
        self.profileImage = profileImage
        self.fullName = fullName
        self.commentByUserId = commentByUserId
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatterGet.timeZone = NSTimeZone(name: TimeZone.current.abbreviation() ?? "GMT+4" ) as TimeZone?
        
        self.createdAt = dateFormatterGet.string(from: Date())
    }
      
}
