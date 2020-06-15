//
//  EnterVerifiViewController.swift
//  hayi-ios2
//
//  Created by Mohsin on 20/09/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import PKHUD
import Alamofire
import Firebase

class Step3VC: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var confirm: RoundButton!
    
    @IBOutlet weak var nextconfimr: RoundButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        email.delegate = self
        password.delegate = self
        confirmPassword.delegate = self
        nextconfimr.isEnabled = false
        nextconfimr.alpha = 0.25
        
        let yourBackImage = UIImage(named: "Back")
        self.tabBarController?.tabBar.isHidden = true

        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        
    }
    
    @IBAction func confimr(_ sender: Any) {
        if validateContactUsFields() {
         if(!isValidPassword(testStr: password.text!)){
            self.DisplayMessage(userMessage: "Atleast 1 UperCase, 1 Numeric & Minimum Length is 6", title: "Password")
            return
            
        } else if (!isValidEmail(email: email.text!)){
            self.DisplayMessage(userMessage: "Invalid Email ", title: "Email")
            return
        }
        
            if(password.text?.elementsEqual(confirmPassword.text!)) != true {
                self.DisplayMessage(userMessage: "Please make sure that password match", title: "Error")
                 return
            }
            else{
                
                // Register User here
                AppManager.email = email.text!
                AppManager.password =  password.text!
                
                self.registerUserOnServer()
                
            }
        }
    }
    
    private func registerUserOnServer(){
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.register)")
        let postString = ["firstName": AppManager.firstName! ,
                          "lastName" : AppManager.familyName!,
                          "email" : AppManager.email!,
                          "password" : AppManager.password! ,
                          "gender": AppManager.courseID!,
                          "neighbourHoodId" : AppManager.neighbourHoodId!,
                          "subCommunityId" : AppManager.subcommunID!]  as [String : Any]
        let MyHeader = ["content-type": "application/json"]
        
        Alamofire.request(url!, method: .post, parameters: postString, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
            DispatchQueue.main.async {
                
                
                switch responseJSON.result{
                    
                case .success(let data):
                   // let decoder = JSONDecoder()
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
                    //AppManager.invoicedata = self.address
                    
                    
                    print("Successfuly fetch relataed data \(data)")
                    
                    
                    let userId = recievedCode.value(forKey: "userId") as? Int
                    
                    
                    UserDefaults.standard.set(userId, forKey: KeyUnApproved)
                    UserDefaults.standard.setValue(AppManager.email, forKey: KeyEmail)
                    UserDefaults.standard.setValue(AppManager.password, forKey: KeyPassword)
                    var success = false
                    
                    if statusCode == 200 && status == 1 && result == true {
                        
                        success = true
                        
                        // RegisterFireBase Users
                        
                        self.registerUserFirebase()
                        
                    }
                    else {
                        success = false
                    }
                    
                    
                    DispatchQueue.main.async {
                    
                        if(success) {
                            //self.customMessage(userMessage: "Successfully Registered", title: "Alert")
                           if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "verifyAddressMapVC") as? verifyAddressMapVC
                           {
                               
                               self.navigationController?.pushViewController(vc, animated: true)
                           }
                            
                        }
                        else {
                            let message = req.value(forKey: "msg") as! String
                            self.DisplayMessage(userMessage: message , title: "Error")
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
    
    func registerUserFirebase() {
        FUser.registerUserWith(email: AppManager.email!, password: AppManager.password!,
                               firstName: AppManager.firstName!.capitalized, lastName: AppManager.familyName!.capitalized) { (error) in
                                
                                if let err = error {
                                    print("Error Registering FireBase User " + err.localizedDescription)
                                }
                                if Messaging.messaging().fcmToken != nil {
                                    
                                    self.updateUserFCMTokenFirebase(token: Messaging.messaging().fcmToken!)
                                    self.updateUserFCMToken(token: Messaging.messaging().fcmToken!)
                                }
                                self.updateExternalChatId()
                                
        }
    }
    
    func updateExternalChatId() {
            
            
            
            let userID = UserDefaults.standard.value(forKey: KeyUnApproved) as? Int
            
            if userID != nil {
                
                let dict:NSDictionary = [kServerUserId:userID!]
                
                updateCurrentUserInFirestore(withValues: dict as! [String : Any], completion: {(error)in
                
                    if let err = error {
                        print(err.localizedDescription)
                    }
                })
            
                
                let currentid = FUser.currentId()
                
                //update External Chat id
                
                let url = HelperFuntions.SaveExternalChatId
                
                let postString = ["userID": userID, "externalChatID": currentid] as [String : Any]
                
                let MyHeader = ["content-type": "application/json"]
                
                Alamofire.request(url, method: .post, parameters: postString, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
                    DispatchQueue.main.async {
                        
                        print("Save External Chat Id")
                       
                            
    //                    case .success(let data):
    //                        var statusCode:Int = 0
    //                        if responseJSON.result.value != nil{
    //
    //                            statusCode = (responseJSON.response?.statusCode)!
    //                            print("...HTTP code: \(statusCode)")
    //                        }
    //
    //
    //                        print(data)
    //                        HUD.hide()
    //                        let recievedCode = data as! NSDictionary
    //                        //                    self.InvoiceListarray  = recievedCode.value(forKeyPath: "InvoiceList") as? NSArray
    //                        self.address = recievedCode.value(forKey: "coordinates") as! NSArray
    //                        let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
    //                        let status = req.value(forKey: "status") as! Int
    //
                
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
    
    func DisplayMessage(userMessage:String , title: String) -> Void {
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
    private func validateContactUsFields()-> Bool {
        
        if !HelperFuntions.validateRequiredField(email.text!){
            
            HelperFuntions.showAlert("Erorr", withMessage: "Please enter first email.")
            return false
        }
        
        if !HelperFuntions.validateRequiredField(password.text!){
            
            HelperFuntions.showAlert("Error", withMessage: "Please enter family password.")
            return false
        }
        if !HelperFuntions.validateRequiredField(confirmPassword.text!){
            
            HelperFuntions.showAlert("Error", withMessage: "Please enter confirm password.")
            return false
        }
        
        
        return true
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
    

    @IBAction func backBtn(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true

    }
}

extension Step3VC : UITextFieldDelegate {
    func textFieldDidChange(_ textField: UITextField)  {
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (email.text!.isEmpty) && (password.text!.isEmpty) && (confirmPassword.text!.isEmpty) {
            nextconfimr.isEnabled = false
            nextconfimr.alpha = 0.5
        }else{
            nextconfimr.isEnabled = true
            nextconfimr.alpha = 1
        }
    }
}
