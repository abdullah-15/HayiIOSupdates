//
//  NotificationsVC.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 18/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class NotificationsVC: UIViewController {
    
    //MARK: Properties
    
    var page = 1
    var length = 20
    var hasNext = true
    var notifications = [Notifications]()
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var noNotificationView: UIImageView!
    
    @IBOutlet weak var notificationTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notificationTable.delegate = self
        self.notificationTable.dataSource = self
        
        notificationTable.tableFooterView = UIView()
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        loadNotifications()
        
        self.notificationTable.refreshControl =  refreshControl
        //refreshControl.attributedTitle = NSAttributedString(string: "Load earlier messages")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    }
    
    func loadNotifications() {
        
        if let userId =  UserDefaultsManager.instance.CurrentUserId() {
            
            
            let url = URL(string: HelperFuntions.getNotifications +  "?id=\(userId)&page=\(self.page)&length=\(self.length)")
            
            
            let MyHeader = ["content-type": "application/json"]
            
            Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
                
                switch responseJSON.result{
                    
                case .success(let data):
                    var statusCode:Int = 0
                    if responseJSON.result.value != nil{
                        
                        statusCode = (responseJSON.response?.statusCode)!
                        print("...HTTP code: \(statusCode)")
                    }
                    
                    let recievedCode = data as! NSDictionary
                    
                    let req = recievedCode.value(forKey: "queryResponse") as! NSDictionary
                    let status = req.value(forKey: "status") as! Int
                    
                    if status == 1 {
                        self.notifications = []
                        if let dict = responseJSON.result.value as? NSDictionary {
                            
                            if let json = JSON(dict.object(forKey: "notifications") as Any).array {
                                
                                for a in json {
                                    let obj = Notifications(json:a)
                                    self.notifications.append(obj)
                                }
                            }
                            DispatchQueue.main.async {
                                
                                if self.notifications.count == 0 {
                                    self.noNotificationView.isHidden = false
                                    self.notificationTable.isHidden = true
                                }
                                else {
                                    self.noNotificationView.isHidden = true
                                    self.notificationTable.isHidden = false
                                }
                                self.notificationTable.reloadData()
                                
                            }
                            
                        }
                    }
                    
                    self.hasNext = recievedCode.value(forKey: "hasNext") as? Bool ?? false
                    
                case .failure(let error):
                    print(error)
                    
                }
                
            }
            
        }
        else {
            self.noNotificationView.isHidden = false
            self.notificationTable.isHidden = true
        }
    }
    
    @objc func refresh(_ sender:AnyObject) {
        self.page = 1
        self.loadNotifications()
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadNotifications()
        
        let obj = self.tabBarController?.tabBar.items?[3]
        if let item = obj {
            item.badgeValue = nil
        }
    }
    
}

extension NotificationsVC : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let not = notifications[indexPath.row]
        
        if let vc =  UIStoryboard(name: "Feeds", bundle: nil).instantiateViewController(withIdentifier: "PresentViewController") as? PresentViewController
        {
            vc.userPostID = not.postId
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notificationTable.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let not = notifications[indexPath.row]
        
        cell.notificationText.text = not.notification
        
        
        if let profile = not.createdUserProfile  {
            
            cell.createdUserAvatar.kf.setImage(with: URL(string:profile))
        }
        else {
            cell.createdUserAvatar.image = UIImage(named: "user (1)")
        }
        
        let dateFormatterGet =  dateFormatter2()
        
        let truncatedDate =  not.createdAt!.components(separatedBy: ".")[0]
        
        let date: Date? = dateFormatterGet.date(from: truncatedDate)
        
        cell.notificationTime.text = dayElapsedData2(date: date!)
        
        return cell
    }
    
}

