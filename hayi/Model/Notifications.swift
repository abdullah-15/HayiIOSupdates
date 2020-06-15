//
//  Notifications.swift
//  hayi
//
//  Created by MacBook Pro on 03/11/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
import SwiftyJSON

class Notifications: Codable {
    
    var userNotificationsId : Int?
    var userId: Int?
    var notification: String?
    var postId: Int?
    var createdAt: String?
    var createdUserProfile: String?
    var notificationCreatedUser: Int?
    var readStatus: Bool?
    
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    public required init(json: JSON) {
        
        userNotificationsId = (json["userNotificationsId"].int)
        userId = (json["userId"].int)
        notification = (json["notification"].string)
        postId = (json["postId"].int)
        createdAt = (json["createdAt"].string)
        createdUserProfile = (json["createdUserProfile"].string)
        notificationCreatedUser = (json["notificationCreatedUser"].int)
        readStatus = (json["notificationCreatedUser"].bool)
        
    }
}
