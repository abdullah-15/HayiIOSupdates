//
//  uiviewcontroller + notificationobserver.swift
//  hayi
//
//  Created by MacBook Pro on 05/01/2020.
//  Copyright © 2020 Hayi. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {
    
    @objc func notificatonArrived(_ notification: NSNotification) {
       //do you updation of labels here
        
        // post notification By Default
        var i = 3
        
        if let type = notification.userInfo?["type"] as? String {
        
            if type == "msg" {
                i = 2
            }
        }
        
            let obj = self.tabBarController?.tabBar.items?[i]
        
            if let tabBarItem = obj {
//                let image = UIImage(named: "Notifications-option")
//                image?.withRenderingMode(.alwaysOriginal)
//                item.image = image
//                if #available(iOS 13.0, *) {
//                    item.image?.withTintColor(.red)
//                } else {
//                    // Fallback on earlier versions
//                }
                
                

                tabBarItem.badgeColor = .clear
                tabBarItem.badgeValue = "●"
                tabBarItem.setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .normal)
                //item.badgeValue = ""
                //item.badgeColor = .red
            }
        
     }
}
