//
//  SettingsVC.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 20/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import MessageUI
import Alamofire

class SettingsVC: UIViewController,MuteNotificationDelegate,MFMailComposeViewControllerDelegate,SendMail {
    
    
    
    
    @IBOutlet weak var settingTable: UITableView!
    
    var simpleList = ["Personal Information","Logout"]
    var settingName = ["Comments","Likes" , "General" , "Recommendations" , "Events" , "Lost & Found" , "Crime Watch" , "Mute All"]
    var actionList = ["Terms & Conditions","Privacy Policy","Contact Us"]
    var settingStates = [true,true,true,true,true,true,true,false]
    var categoryOption = [0,0,1,2,3,4,5,6]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTable.registerTableCellsAndHeaders(cells: ["simpleCell" , "HeaderCell" , "SettingCell","ActionCell"])
        settingTable.tableFooterView = UIView()
        //     navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        //
        //    let yourBackImage = UIImage(named: "Back")
        //
        //
        //    self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        //    self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        
        getUserNotificationOptions()
        
    }
    //    override func viewWillDisappear(_ animated: Bool)
    //    {
    //        super.viewWillDisappear(animated)
    //        self.navigationController?.isNavigationBarHidden = false
    //    }
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        self.navigationController?.isNavigationBarHidden = true
    //    }
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false
        
        self.navigationController?.isNavigationBarHidden = true
        
        
    }
    
    func getUserNotificationOptions() {
        let userId = UserDefaultsManager.instance.CurrentUserId()
        
        let url = URL(string:"\(HelperFuntions.getNotificationOptions)\(userId!)")
        
    
        let MyHeader = ["content-type": "application/json"]
        
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
            DispatchQueue.main.async {
                
                switch responseJSON.result{
                    
                case .success(let data):
                    var statusCode:Int = 0
                    if responseJSON.result.value != nil{
                        
                        statusCode = (responseJSON.response?.statusCode)!
                        print("...HTTP code: \(statusCode)")
                    }
                    
                    print(data)
                    
                    let recievedCode = data as! NSDictionary
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let notificationsOptions = recievedCode.value(forKey: "notifications") as! NSDictionary
                    let settingStateOptions =  notificationsOptions.value(forKey: "settingState") as! NSArray
                    
                    for i in 0..<settingStateOptions.count {
                        
                        self.settingStates[i] = settingStateOptions[i] as! Int == 1 ? true: false
                    }
                    
                    self.settingTable.reloadData()
                    
                case .failure(let error):
                    print(error)
                    
                    
                }
                
            }
    }
}
}
extension SettingsVC: UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 2
        case 1:
            return settingName.count
        case 2:
            return actionList.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cellstatic = settingTable.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! simpleCell
            cellstatic.configureCell(title: self.simpleList[indexPath.row])
            
            return cellstatic
        }
        else if indexPath.section == 1 {
            let cellstatic = settingTable.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
            cellstatic.configureCell(label: self.settingName[indexPath.row],state: self.settingStates[indexPath.row])
            cellstatic.asignTag(tag: indexPath.row)
            cellstatic.delgate = self
            return cellstatic
        }
        else {
            let cellstatic = settingTable.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell
            cellstatic.configureCell(title: self.actionList[indexPath.row],tagValue: indexPath.row)
            cellstatic.delegate = self
            return cellstatic
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func TurnOffAll(state: Bool) {
        
        if state {
            
            for i in 0...self.settingStates.count - 2 {
                self.settingStates[i] = !state
            }
        }
        self.settingStates[self.settingStates.count - 1 ] = state
        self.settingTable.reloadData()
        
        self.MuteAllNotifications()
    }
    func Mute(tag: Int,state: Bool) {
        
        self.settingStates[tag] = state
        self.settingTable.reloadData()
        
        var type:Int = 0
        var categoryId = 0
        var ostate = 0
        
        if state {
            ostate = 1
        }
        else {
            ostate = 0
        }
        
        if tag == 0 {
            type = 2
        }
        else if tag == 1 {
            type = 1
        }
        else {
            categoryId = self.categoryOption[tag]
        }
        
        self.MuteCategoryNotification(type: type, state: ostate, categoryId: categoryId)
    }
    
    func SendMail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["admin@hayi.app"])
            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            
            HelperFuntions.showAlert("Error", withMessage: "Please setup email account in your device settings")
            
        }
    }
    func ShowTermsConditions() {
        
        guard let url = URL(string: "https://www.hayi.app/terms-conditions") else {
          return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }
    func ShowPrivacyPolicy() {
        
        guard let url = URL(string: "https://www.hayi.app/privacy-policy") else {
          return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    func MuteAllNotifications() {
        
        
        let userId = UserDefaults.standard.value(forKey: KeyUserId) as? Int
        
        if userId != nil {
            
            let url = HelperFuntions.MuteAllNotificationOption
            
            let postString = ["userId": userId!] as [String : Any]
            
            let MyHeader = ["content-type": "application/json"]
            
            Alamofire.request(url, method: .post, parameters: postString, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
                DispatchQueue.main.async {
                    
                    print("Save FCM Token")
                    
                    switch responseJSON.result{
                        
                    case .success(let data):
                        var statusCode:Int = 0
                        if responseJSON.result.value != nil{
                            
                            statusCode = (responseJSON.response?.statusCode)!
                            print("...HTTP code: \(statusCode)")
                        }
                        print("all reponse data \(data)")
                        
                    case .failure(let error):
                        print(error)
                        //HUD.hide()
                    }
                    
                }
            }
        }
        
    }
    
    func MuteCategoryNotification(type:Int,state:Int,categoryId:Int) {
        
        let userId = UserDefaults.standard.value(forKey: KeyUserId) as? Int
        
        if userId != nil {
            
            let url = HelperFuntions.UpdateNotificationOption
            
            let postString = ["userId": userId!,"categoryId":categoryId,"type":type,"switch":state] as [String : Any]
            
            let MyHeader = ["content-type": "application/json"]
            
            Alamofire.request(url, method: .post, parameters: postString, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
                    
                    switch responseJSON.result{
                        
                    case .success(let data):
                        var statusCode:Int = 0
                        if responseJSON.result.value != nil{
                            
                            statusCode = (responseJSON.response?.statusCode)!
                            print("...HTTP code: \(statusCode)")
                        }
                        print("all reponse data \(data)")
                    case .failure(let error):
                        print(error)
                        //HUD.hide()
                    }
                    
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            
            
            if let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "UserInfoViewController") as? UserInfoViewController
            {
                // NotificationCenter.default.post(name: Notification.Name("loadData"), object: nil)
                AppManager.globalCheck = 1
                vc.isloggedInUser = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            // self.performSegue(withIdentifier: "goToProfileInformation", sender: self)
        } else if indexPath.section == 0 && indexPath.row == 1 {
            
            ConfirmLogout()
            
        }
        
    }
    
    func ConfirmLogout() -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Log out", message: "Do you really want to log out", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default){(
                ACTION:UIAlertAction!) in
                //self.emptyAllTextFields()
                
            }
            alertController.addAction(cancelAction)
            
            let okAction = UIAlertAction(title: "OK", style: .default){(
                ACTION:UIAlertAction!) in
                //self.emptyAllTextFields()
                
                let userId = UserDefaultsManager.instance.CurrentUserId()!
                
                self.UpdateFCMToken(userId:userId ,token:"")
                
                
                UserDefaultsManager.instance.logOut()
                
                UserDefaultsManager.instance.setValueFor(value: nil, key: KIsRegisteredFirebase)
                
                FUser.logOutCurrentUser { (val) in
                    print("Firebase logout")
                }
                
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "MainScreenVC") as? MainScreenVC
                {
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = settingTable.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell
        switch section {
        case 0:
            headerCell.configureCell(title:  "Account")
        case 1:
            headerCell.configureCell(title:  "Notification Settings")
        case 2:
            headerCell.configureCell(title:  "Help")
        default:
            print("some issue")
        }
        return headerCell
    }
    
    func UpdateFCMToken(userId: Int, token: String){
        
        let url = HelperFuntions.UpdateUserFCMToken
        
            let postString = ["userId": userId, "fcmToken": token] as [String : Any]
            
            let MyHeader = ["content-type": "application/json"]
            
            Alamofire.request(url, method: .post, parameters: postString, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
                DispatchQueue.main.async {
                    
                    print("Save FCM Token")
                    
                    switch responseJSON.result{
                        
                    case .success(let data):
                        var statusCode:Int = 0
                        if responseJSON.result.value != nil{
                            
                            statusCode = (responseJSON.response?.statusCode)!
                            print("...HTTP code: \(statusCode)")
                        }
                        print("all reponse data \(data)")
                        
                    case .failure(let error):
                        print(error)
                        //HUD.hide()
                    }
                }
        }
    }
}
