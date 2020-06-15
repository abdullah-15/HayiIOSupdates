//
//  FHelpers.swift
//  hayi-ios2
//
//  Created by MacBook Pro on 26/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
import Firebase



func getFirebaseUserByExternalChatId(externalChatId: String) -> FUser? {
    
    var allUsers: [FUser] = []

    let query = reference(.User).whereField(kUSERID, isEqualTo: FUser.currentUser()!.city).order(by: kFIRSTNAME, descending: false)
    
    query.getDocuments { (snapshot, error) in
        
        
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        guard let snapshot = snapshot else {
            print("SnapShot is Empty")
            return
        }
        
        
        if !snapshot.isEmpty {
            
            for userDictionary in snapshot.documents {
                
                let userDictionary = userDictionary.data() as NSDictionary
                let fUser = FUser(_dictionary: userDictionary)
                
                if fUser.objectId != FUser.currentId() {
                    allUsers.append(fUser)
                }
            }
            
            
        }
    }
    return allUsers.last
}



