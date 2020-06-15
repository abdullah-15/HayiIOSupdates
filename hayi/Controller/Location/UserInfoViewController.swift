//
//  UserInfoViewController.swift
//  hayi-ios2
//
//  Created by Mohsin on 26/09/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import SDWebImage

struct userSkills:Equatable {
    var sname : String?
    var sid: Int?
}
struct userInterest:Equatable {
    var iName : String?
    var sid: Int?
}

class UserInfoViewController: UIViewController {
    var userInterestList = [userInterest]()
    var userSkillsList = [userSkills]()
    var chatUser: FUser?
    
    @IBOutlet weak var sendMessageButton: RoundButton!
    
    
    @IBOutlet weak var profileDetailParentView: UIView!
    @IBAction func sendMessageButtonPressed(_ sender: RoundButton) {
        
        print("Button Message Pressed")

            self.startPrivateChat()
        
    }
    @IBOutlet weak var detailHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var myImg: UIImageView!
    @IBOutlet weak var jobtitle: UILabel!
    @IBOutlet weak var image1: RoundImage!
    @IBOutlet weak var nationality: UILabel!
    
    @IBOutlet weak var residence: UILabel!
    @IBOutlet weak var subCommunity: UILabel!
    @IBOutlet weak var neighbourHood: UILabel!
    
    @IBOutlet weak var profileHeaderContainer: NSLayoutConstraint!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var collection1: UICollectionView!
    var boundries : NSDictionary = NSDictionary()
    var profileInfromation : NSDictionary = NSDictionary()
    var interest : NSArray = NSArray()
    var skills : NSArray = NSArray()
    var userID : Int?
    var externalChatId: String?
    var userName : String?
    var profileImage : String?
    var isloggedInUser = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection1.delegate = self
        collection1.dataSource = self
        self.title = "Profile"
        self.tabBarController?.tabBar.isHidden = true
       
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        let userId = UserDefaultsManager.instance.CurrentUserId()
        
        if isloggedInUser || userId == self.userID  {
            loadProfileFromDefaults()
        }
        else {
            getProfileInfo()
        }
        
        
        if AppManager.globalCheck == 1 {
            
            let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
            //set image for button

            button.setImage(UIImage(named: "user-edit"), for: UIControl.State.normal)
            
            
            //add function for button
            button.addTarget(self, action: #selector(UserInfoViewController.didTapEditButton), for: UIControl.Event.touchUpInside)
            
            //set frame
            button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            
            let editButton = UIBarButtonItem(customView:button)
            
            navigationItem.rightBarButtonItems = [editButton]
            //getProfileInfo()
        }else if AppManager.globalCheck == 2{
//            self.name.text = userName
//            var imageurl = profileImage
//            if imageurl != nil {
//                print("imageurl ::\(String(describing: imageurl))")
//
//
//                imageurl = imageurl!.replacingOccurrences(of: " ", with: "%20")
//
//                imageurl = "https://\(imageurl!)"
//                print("imageUrl ----\(imageurl!)")
//                self.myImg.layer.cornerRadius = self.myImg.frame.height/2
//                self.myImg.sd_setImage(with: URL(string:imageurl!))
//
//            }
        }
        
        
    }
    
    
    
    @objc func didTapEditButton(sender: AnyObject){
        
        if let vc =  UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "UserEditProfileViewController") as? UserEditProfileViewController
        {
         
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
        let userId = UserDefaultsManager.instance.CurrentUserId()
             
          
        if(!self.isloggedInUser && userId != self.userID) {
            if self.externalChatId != nil {
                loadChatUser()
            }
        }
        else {
            loadProfileFromDefaults()
        }
    }
    
    
    @IBAction func Edit(_ sender: Any) {
        
    }
    
}

//MARK: Load User Profile

extension UserInfoViewController {
    
    func loadProfileFromDefaults() {
        
        self.userInterestList.removeAll()
        self.userSkillsList.removeAll()
        let userId = UserDefaultsManager.instance.CurrentUserId()
             
        if(self.isloggedInUser || userId == self.userID) {
            self.userID =  UserDefaults.standard
                .value(forKey: "userID") as? Int
            
            self.sendMessageButton.isHidden = true
            
            self.detailHeightConstraint.constant = 0
            
            
            
        }
        else {
            self.sendMessageButton.isHidden = false
        }
        
        let defaults = UserDefaultsManager.instance
        
        self.name.text = (defaults.getValueFor(key: KeyFirstName) ?? "") + " " + (defaults.getValueFor(key: KeyLastName) ?? "")
        
        self.subCommunity.text = defaults.getValueFor(key: KeySubCommunity) ?? " "
        self.neighbourHood.text = defaults.getValueFor(key: KeyNeighbourHood) ?? " "
        
        let subname = self.subCommunity.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let neihName = self.neighbourHood.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if subname == neihName {
            self.neighbourHood.isHidden = true
            self.neighbourHood.frame.size.height = 0
            self.profileHeaderContainer.constant = 230
        }
        else {
            self.neighbourHood.isHidden = false
            self.neighbourHood.frame.size.height = 20
            self.profileHeaderContainer.constant = 250
        }
        
        self.nationality.text = defaults.getValueFor(key: KeyNationality) ?? ""
        self.jobtitle.text = defaults.getValueFor(key: KeyJobTitle) ?? ""
        self.residence.text = defaults.getValueFor(key: KeyResidentSince) ?? ""
        
        
        //Setting placeholders in case ono value
        
        if self.nationality.text == "" {
            
            self.nationality.text = "Not Available"
            self.nationality.textColor = UIColor.lightGray
        }
        else {
            self.nationality.textColor = UIColor.black
        }
        
        if self.jobtitle.text == "" {
            
            self.jobtitle.text = "Not Available"
            self.jobtitle.textColor = UIColor.lightGray
        }
        else {
            self.jobtitle.textColor = UIColor.black
        }
        
        if self.residence.text == "" {
            
            self.residence.text = "Not Available"
            self.residence.textColor = UIColor.lightGray
        }
        else {
            self.residence.textColor = UIColor.black
        }
        
        
        var profileImg:String? = defaults.getValueFor(key: KeyProfileImage)
        
        if profileImg != nil {
            
            profileImg = profileImg!.replacingOccurrences(of: " ", with: "%20")
            profileImg = "\(profileImg!)"
            
            self.myImg.layer.cornerRadius = self.myImg.frame.height/2
            self.myImg.clipsToBounds = true
            self.myImg.sd_setImage(with: URL(string:profileImg!))
        }
        else {
            
            let firstname = defaults.getValueFor(key: KeyFirstName)
            let lastname = defaults.getValueFor(key: KeyLastName)
            
            imageFromInitials(firstName: firstname, lastName: lastname) { (image) in
                DispatchQueue.main.async {
                    self.myImg.image = image
                }
            }
        }
        
        
        self.interest = defaults.getInterests()
        
        print(self.interest)
        
        for i in 0..<self.interest.count {
            let dic = self.interest[i] as! NSDictionary
            // let interest =  self.profileInfromation["interest"]
            let name =  dic["name"] as? String
            let id =  dic["interestId"] as? Int
            
            let obj = userInterest(iName: name, sid: id)
            
            self.userInterestList.append(obj)
            
        }
        self.collection1.reloadData()
        
    }
    
    func getProfileInfo() {
        self.userInterestList.removeAll()
        self.userSkillsList.removeAll()
        if(self.isloggedInUser) {
            self.userID =  UserDefaults.standard
                .value(forKey: "userID") as? Int
            
            self.sendMessageButton.isHidden = true
        }
        else {
            self.sendMessageButton.isHidden = false
        }
        
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.getProfile)")
        let postString = ["userID": self.userID! ] as [String : Any]
        let MyHeader = ["content-type": "application/json"]
        
        Alamofire.request(url!, method: .post, parameters: postString, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
            DispatchQueue.main.async {
                
                HUD.hide()
                switch responseJSON.result{
                    
                case .success(let data):
                    var statusCode:Int = 0
                    if responseJSON.result.value != nil{
                        
                        statusCode = (responseJSON.response?.statusCode)!
                        print("...HTTP code: \(statusCode)")
                    }
                    print("Neighbourhood data \(data)")
                    
                    
                    
                    let recievedCode = data as! NSDictionary
                    
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let status = req.value(forKey: "status") as! Int
                
                    let result =  req.value(forKey: "result") as! Bool
                    
                    self.profileInfromation = recievedCode.value(forKey: "userProfile") as! NSDictionary
                    
                    if statusCode == 200 && status == 1 && result == true {
                        
                        self.externalChatId = self.profileInfromation["externalChatId"] as? String
                        
                        self.loadChatUser()
                        
                    }
                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1 && result == true {
                            print(self.profileInfromation)
                            
                            let name = self.profileInfromation["firstName"] as? String
                            let lastName =  self.profileInfromation["lastName"] as? String
                            let nationality = self.profileInfromation["nationality"] as? String
                            let residence =  self.profileInfromation["residentSince"] as? String
                            let jobitile = self.profileInfromation["jobTitle"] as? String
                            
                            self.subCommunity.text = self.profileInfromation[KeySubCommunity] as? String
                            self.neighbourHood.text = self.profileInfromation[KeyNeighbourHood] as? String
                            
                            let subname = self.subCommunity.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                            let neihName = self.neighbourHood.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            if subname == neihName {
                                self.neighbourHood.isHidden = true
                                self.neighbourHood.frame.size.height = 0
                                self.profileHeaderContainer.constant = 230
                            }
                            else {
                                self.neighbourHood.isHidden = false
                                self.neighbourHood.frame.size.height = 20
                                self.profileHeaderContainer.constant = 250
                            }
                            
                            if name != nil {
                                self.name.text = name! + " " + (lastName != nil ? lastName!: "")
                            }
                            if nationality != nil {
                                self.nationality.text = nationality
                                
                            }
                            if jobitile != nil {
                                self.jobtitle.text = jobitile
                                
                            }
                            if residence != nil {
                                self.residence.text = residence
                            }
                            
                            
                            var imageurl = self.profileInfromation["profileImage"] as? String
                            
                            if imageurl != nil {
                                
                                imageurl = imageurl!.replacingOccurrences(of: " ", with: "%20")
                                imageurl = "\(imageurl!)"
                                
                                self.myImg.layer.cornerRadius = self.myImg.frame.height/2
                                self.myImg.clipsToBounds = true
                                self.myImg.sd_setImage(with: URL(string:imageurl!))
                                
                            }
                            
                            self.interest = self.profileInfromation["interest"] as! NSArray
                            
                            
                            for i in 0..<self.interest.count {
                                let dic = self.interest[i] as! NSDictionary
                                // let interest =  self.profileInfromation["interest"]
                                let name =  dic["name"] as? String
                                let id =  dic["interestId"] as? Int
                                
                                let obj = userInterest(iName: name, sid: id)
                                
                                self.userInterestList.append(obj)
                                
                                self.collection1.reloadData()
                                
                            }
                            
                          
                            
                            
                        }
                        
                    }
                    if statusCode == 401{
                        
                    }
                case .failure(let error):
                    print(error)
                    HUD.hide()
                }
            }
            
        }
    }
    
}



//MARK: Chat Functionality
extension UserInfoViewController {
    
    func loadChatUser() {
        
        if let chatId = self.externalChatId {
            
            let query = reference(.User).whereField("objectId", isEqualTo: chatId)
            
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
                        
                        self.chatUser = fUser
                        
                    }
                    
                }
            }
            
        }
    }
    
    func startPrivateChat() {
        
        if let user = self.chatUser {
            
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
            if let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as?   ChatViewController
                
            {
                 chatVC.titleName = user.firstname
                           chatVC.membersToPush = [FUser.currentId(), user.objectId]
                           chatVC.memberstoFCMPush = [FUser.currentUser()!.FCMToken,user.FCMToken]
                           chatVC.memberIds = [FUser.currentId(), user.objectId]
                           chatVC.title = "Messages"
                chatVC.chatRoomId = Hayi.startPrivateChat(user1: FUser.currentUser()!, user2: user)
                           
                           chatVC.hidesBottomBarWhenPushed = true
                
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
            
        }
        
    }
    
}


//MARK: Skills And Interests
extension UserInfoViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collection1 {
            return  self.userInterestList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cellA = self.collection1.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! UserInterestCell
            cellA.lblInterest.text = userInterestList[indexPath.row].iName
            // Set up cell
            cellA.lblInterest.frame.size.width = cellA.lblInterest.text?.width(constraintedheight: 30, fontSize: 15, text: cellA.lblInterest.text ?? "") ?? 60
            cellA.labelContainer.frame.size.width = cellA.lblInterest.text?.width(constraintedheight: 30, fontSize: 15,text: cellA.lblInterest.text ?? "") ?? 60
            
            cellA.labelContainer.layer.cornerRadius = 10
            
            return cellA
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let text = userInterestList[indexPath.row].iName
        
        //let fontAttributes = NSAttributedString.Key.font: UIFont(name: UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
        
        let width = text?.width(constraintedheight: 30, fontSize: 15,text: text ?? "") ?? 60
        
        return CGSize(width: width + 10 , height: 30)
    }
    
}
