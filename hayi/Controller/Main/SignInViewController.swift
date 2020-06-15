//
//  SignInViewController.swift
//  hayi-ios2
//
//  Created by Mohsin on 20/09/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import SwiftKeychainWrapper
import Firebase

class SignInViewController: UIViewController {
    var userProfile : NSDictionary = NSDictionary()
    var loginuser : Login?
    var name : String?
    var emailuser : String?
    var passworduser : String?
    
    @IBOutlet weak var login: RoundButton!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        
        let yourBackImage = UIImage(named: "Back")
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        loginuser = Login()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(_ sender: Any) {
        
        if validateContactUsFields(){
            
            if Connectivity.isConnectedToInternet(){
                
                self.SignIn()
            }else{
                self.DisplayMessage(userMessage: internetNot, title: "Info")
            }
            
        }
    }
    
    @IBAction func actionPrivacy(_ sender: UIButton) {
        guard let url = URL(string: "https://www.hayi.app/privacy-policy") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func actionTermsAndConditions(_ sender: UIButton) {
        guard let url = URL(string: "https://www.hayi.app/terms-conditions") else { return }
        UIApplication.shared.open(url)
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        //        if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "Step1VC") as? Step1VC
        //        {
        //
        //            self.navigationController?.pushViewController(vc, animated: true)
        //        }
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "Step1VC") as? Step1VC
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
        //self.performSegue(withIdentifier: "login", sender: self)
        
    }
    private func validateContactUsFields()-> Bool {
        
        if !HelperFuntions.validateRequiredField(email.text!){
            
            HelperFuntions.showAlert("Erorr", withMessage: "Please enter first email.")
            return false
        }
        
        if !HelperFuntions.validateRequiredField(password.text!){
            
            HelperFuntions.showAlert("Error", withMessage: "Please enter  password.")
            return false
        }
        
        
        return true
    }
    private func SignIn(){
        
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        
        
        let url = URL(string:"\(HelperFuntions.signIn)")
        
        let postString = ["email": email.text! ,
                          "password" : password.text!]  as [String : Any]
        let MyHeader = ["content-type": "application/json"]
        
        Alamofire.request(url!, method: .post, parameters: postString, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
            DispatchQueue.main.async {
                
                switch responseJSON.result{
                    
                case .success(let data)
                    :
                    
                    var statusCode:Int = 0
                    if responseJSON.result.value != nil{
                        
                        statusCode = (responseJSON.response?.statusCode)!
                        print("...HTTP code: \(statusCode)")
                    }
                    
                    print(data)
                    HUD.hide()
                    let recievedCode = data as! NSDictionary
                    
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let result = req.value(forKey: "result") as! Bool
                    let status = req.value(forKey: "status") as! Int
                    let msg = req.value(forKey: "msg") as! String
                    let profilestatus = recievedCode.value(forKey: "profileStatuts") as! Int
                    let userId = recievedCode.value(forKey: "userId") as! Int
                    let neighbourHoodId = recievedCode.value(forKey: "neighbourHoodId") as! Int
                    let subCommunityId = recievedCode.value(forKey: "subCommunityId") as! Int
                    let neighbourHoodName = recievedCode.value(forKey: "neighbourHoodName") as? String
                    let subCommunityName = recievedCode.value(forKey: "subCommunityName") as? String
                    
                    //let profilestatus = 3
                    //AppManager.invoicedata = self.address
                    
                    if (result == true) {
                        print("Successfuly fetch relataed data \(data)")
                        DispatchQueue.main.async {
                        if statusCode == 200  {
                            
                            self.emailuser = self.email.text!
                            self.passworduser = self.password.text!
                            
                            
                            
                            if let message = recievedCode["access_token"]{
                                print(message)
                                let saveSuccessful: Bool = KeychainWrapper.standard.set(message as! String, forKey: "token")
                                print("Save was successful: \(saveSuccessful) email verfied ")
                                
                                
                            }
                            
                            if profilestatus == 1 || profilestatus == 4 || profilestatus == 0
                            {
                                UserDefaults.standard.set(userId,forKey: KeyUnApproved)
                                UserDefaults.standard.synchronize()
                                
                                if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "verifyAddressMapVC") as? verifyAddressMapVC
                                {
                                    
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                                AppManager.neighbourHoodId =  neighbourHoodId
                                AppManager.subcommunID =  subCommunityId
                                AppManager.neighbourHoodName =  neighbourHoodName
                                AppManager.subCommunityName = subCommunityName
                            }
                            if profilestatus == 2 {
                                self.DisplayMessageSuspend(userMessage: "Account verification is Pending", title: "")
                            }
                            
                            if profilestatus == 3 {
                                
                                UserDefaultsManager.instance.SaveLoginDetails(email: self.emailuser!, password: self.passworduser!, profileStatus: 3,userId: userId,neighbourHoodId: neighbourHoodId,subCommunityId: subCommunityId)
                                
                                self.getProfileInfo()
                                
                                
                                
                                // self.DisplayMessage(userMessage: "Success", title: "")
                                
                                //                                if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "DashBoardTabBarController") as? DashBoardTabBarController
                                //                                {
                                //
                                //                                    self.navigationController?.pushViewController(vc, animated: true)
                                //                                }
                            }
                            if profilestatus == 5 {
                                self.DisplayMessageSuspend(userMessage: "Your account has been suspended", title: "")
                            }
                            
                            
                            
                        }
                        
                    }
                    }
                    else {
                        
                        self.DisplayMessage(userMessage: msg , title: "Error")
                    }
                    if statusCode == 401{
                        self.custom(userMessage: "Error", title: "Alert")
                        
                    }
                case .failure(let error):
                    print(error)
                    HUD.hide()
                }
                
                
                
                
            }
            
        }
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
    
    func DisplayMessage(userMessage:String , title: String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: userMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default){(
                ACTION:UIAlertAction!) in
                //self.emptyAllTextFields()
                //                if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "DashBoardTabBarController") as? DashBoardTabBarController
                //                {
                //
                //                    self.navigationController?.pushViewController(vc, animated: true)
                //                }
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    func DisplayMessageSuspend(userMessage:String , title: String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: userMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default){(
                ACTION:UIAlertAction!) in
                //self.emptyAllTextFields()
                
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    func isValidPassword(testStr:String?) -> Bool {
        guard testStr != nil else { return false }
        
        // at least one uppercase,
        // at least one digit
        // at least one lowercase
        // 8 characters total
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6,}")
        return passwordTest.evaluate(with: testStr)
    }
    func isValidEmail(email:String?) -> Bool {
        
        guard email != nil else { return false }
        
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func custom(userMessage:String , title: String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: userMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default){(
                ACTION:UIAlertAction!) in
                //self.emptyAllTextFields()
                //                if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "DashBoardTabBarController") as? DashBoardTabBarController
                //                {
                //
                //                    self.navigationController?.pushViewController(vc, animated: true)
                //                }
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    //    override func viewWillAppear(_ animated: Bool) {
    //         self.navigationController?.isNavigationBarHidden = false
    //        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    //    }
    
    
    @IBAction func forgotPasswrd(_ sender: Any) {
        if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "ForgotViewController") as? ForgotViewController
        {
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    
    private func getProfileInfo(){
        
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        
        let url = URL(string:"\(HelperFuntions.getProfile)")
        
        let postString = ["userID": UserDefaults.standard
            
            .value(forKey: "userID")!] as [String : Any]
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
                    
                    print("response data \(data)")
                    
                    let recievedCode = data as! NSDictionary
                    
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let status = req.value(forKey: "status") as! Int
                    let result =  req.value(forKey: "result") as! Bool
                    
                    DispatchQueue.main.async {
                        
                        if statusCode == 200 && status == 1 && result == true {
                            
                            self.userProfile = recievedCode.value(forKey: "userProfile") as! NSDictionary
                            
                            let interests = self.userProfile.value(forKey: "interest") as? NSArray
                            
                            let skills = self.userProfile.value(forKey: "skills") as? NSArray
                            
                            
                            UserDefaultsManager.instance.SaveUserProfile(data: self.userProfile,skills: skills, interests:interests)
                            
                            if (UserDefaultsManager.instance.getValueFor(key: KeyExternalChatId) == nil) {
                                
                                self.RegisterOnFirebase()
                                
                            }
                            else {
                                
                                self.loginFirebase()
                                
                            }
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                    HUD.hide()
                }
                
                
                
                
            }
            
        }
    }
    func saveDictionary(dict: Dictionary<Int, String>, key: String){
        let preferences = UserDefaults.standard
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: dict)
        preferences.set(encodedData, forKey: key)
        // Checking the preference is saved or not
    }
    
    func updateExternalChatId() {
        
        if  FUser.currentUser() != nil {
            
            let currentid = FUser.currentId()
            
            let userId = UserDefaultsManager.instance.CurrentUserId()
            
            let url = HelperFuntions.SaveExternalChatId
            
            let postString = ["userID": userId, "externalChatID": currentid] as [String : Any]
            
            let MyHeader = ["content-type": "application/json"]
            
            Alamofire.request(url, method: .post, parameters: postString, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
                print("Save External Chat Id")
            }
        }
    }
    
    func loginFirebase() {
        
        let username = UserDefaults.standard.string(forKey: KeyEmail)
        let userpassword = UserDefaults.standard.string(forKey: KeyPassword)
        
        
        FUser.loginUserWith(email: username!, password: userpassword!) { (error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                
                if Messaging.messaging().fcmToken != nil {
                    
                    self.updateUserFCMTokenFirebase(token: Messaging.messaging().fcmToken!)
                    self.updateUserFCMToken(token: Messaging.messaging().fcmToken!)
                }
                
                
                if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "DashBoardTabBarController") as? DashBoardTabBarController
                {
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }
    }
    
    func RegisterOnFirebase() {
        
        let defaults = UserDefaultsManager.instance
        
        let email = defaults.getValueFor(key: KeyEmail)
        let password = defaults.getValueFor(key: KeyPassword)
        let firstName = defaults.getValueFor(key: KeyFirstName)
        let lastName = defaults.getValueFor(key: KeyLastName)
        let avatar = defaults.getValueFor(key: KeyProfileImage)
        
        if avatar != nil {
            FUser.registerUserWith(email: email!, password: password!, firstName: firstName!, lastName: lastName!,avatar: avatar!) { (error) in
                
                if error == nil {
                    defaults.setValueFor(value: "1",key: KIsRegisteredFirebase)
                    self.updateExternalChatId()
                }
                else {
                    defaults.setValueFor(value: nil,key: KIsRegisteredFirebase)
                }
                
            }
            
        }
        else {
            
            FUser.registerUserWith(email: email!, password: password!, firstName: firstName!, lastName: lastName!) { (error) in
                
                if error == nil {
                    
                    defaults.setValueFor(value: "1",key: KIsRegisteredFirebase)
                    self.updateExternalChatId()
                }
                else {
                    defaults.setValueFor(value: nil,key: KIsRegisteredFirebase)
                    
                }
            }
        }
    }
    func updateUserFCMToken(token:String) {
        
        let userId = UserDefaults.standard.value(forKey: KeyUserId) as? Int
        
        if userId != nil {
            
            let url = HelperFuntions.UpdateUserFCMToken
            
            let postString = ["userId": userId!, "fcmToken": token] as [String : Any]
            
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
    
    func updateUserFCMTokenFirebase(token:String) {
        
        let dict:NSDictionary = [kFCMToken:token]
        
        updateServerUserId(withValues: dict as! [String : Any], completion: {(error)in
            
            if let err = error {
                print(err.localizedDescription)
            }
        })
    }
    
    
}
