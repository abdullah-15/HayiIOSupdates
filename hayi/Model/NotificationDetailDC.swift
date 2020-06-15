//
//  NotificationDetailDC.swift
//  PTCustomerTrainer
//
//  Created by Ali Raza on 26/05/2019.
//  Copyright © 2019 Ali Raza. All rights reserved.
//

import UIKit

@objcMembers class NotificationDetailDC: NSObject {
    var otherUserUID = ""
    var otherUserId = ""
    var chat = ""
    var profileImage = ""
    var lastName = ""
    var firstName = ""
    var chatRoomId = ""
    var aps = NotificationApsDC()
}

@objcMembers class NotificationApsDC: NSObject {
    var alert = NotificationAlertDC()
    
}

@objcMembers class NotificationAlertDC: NSObject {
    var title = ""
    var body = ""
}
