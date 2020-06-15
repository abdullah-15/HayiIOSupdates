//
//  ParsingDicFunctions.swift
//  hayi
//
//  Created by Ali Raza on 09/06/2020.
//  Copyright © 2020 Hayi. All rights reserved.
//

import Foundation

class ParsingDicFunctions: NSObject {
    //MARK: Notification methods
    func parseNotficationDetail(_ dic: NSDictionary) -> NotificationDetailDC{
        
        let obj = NotificationDetailDC()
        let keys = notificationDetailKeys()
        
        for j in 0 ..< keys.count {
            
            if dic.value(forKey: keys[j]) != nil {
                
                if !(dic.value(forKey: keys[j]) is NSNull) {
                    if keys[j] == "aps"{
                        if let aps = dic.value(forKey: keys[j]) as? NSDictionary {
                            obj.setValue(self.parseAps(aps), forKey: keys[j])
                        }
                    }else {
                        obj.setValue(dic.value(forKey: keys[j]), forKey: keys[j])
                    }
                }
            }
        }
        return obj
    }
    
    func parseAps(_ dic: NSDictionary) -> NotificationApsDC {
        
        let obj = NotificationApsDC()
        
        let keys = notificationApsKeys()
        
        for j in 0 ..< keys.count {
            
            if dic.value(forKey: keys[j]) != nil {
                
                if !(dic.value(forKey: keys[j]) is NSNull) {
                    if keys[j] == "alert" {
                        if let alert = dic.value(forKey: keys[j]) as? NSDictionary {
                            obj.setValue(self.parseApsAlert(alert), forKey: keys[j])
                        }
                    }
                }
            }
        }
        
        return obj
    }
    
    func parseApsAlert(_ dic: NSDictionary) -> NotificationAlertDC {
        
        let obj = NotificationAlertDC()
        
        let keys = notificationApsAlertKeys()
        
        for j in 0 ..< keys.count {
            
            if dic.value(forKey: keys[j]) != nil {
                
                if !(dic.value(forKey: keys[j]) is NSNull) {
                    
                    obj.setValue(dic.value(forKey: keys[j]), forKey: keys[j])
                }
            }
        }
        
        return obj
    }
    
    //MARK: - Keys Arrays Methods
    private func notificationDetailKeys() -> [String]{
        return ["otherUserUID", "otherUserId", "aps", "chat", "profileImage", "lastName", "firstName", "chatRoomId"]
    }
    
    private func notificationApsKeys() -> [String]{
        return ["alert"]
    }
    
    private func notificationApsAlertKeys() -> [String]{
        return ["body", "title"]
    }
}
