//
//  ForgotViewController.swift
//  hayi-ios2
//
//  Created by Mohsin on 27/09/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class ForgotViewController: UIViewController {
    var userOtp : String?
    @IBOutlet weak var email: UITextField!
    weak var actionToEnable : UIAlertAction?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        let yourBackImage = UIImage(named: "Back")
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)

        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)

        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.title = "Update Password"

        // Do any additional setup after loading the view.
    }
    
    

    @IBAction func password(_ sender: Any) {
    
        if validateContactUsFields(){
            if Connectivity.isConnectedToInternet(){
                ForgotPassword()
            }else{
                self.DisplayNet(userMessage: internetNot, title: "Info")
            }
        }
    }
    
    // MARK: - Navigation
    
    
    func DisplayMessage(userMessage:String , title: String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: userMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default){(
                ACTION:UIAlertAction!) in
                self.ValidateOTP()
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    func ValidateOTP()
    {
        let titleStr = "OTP"
        let message = "Enter OTP Received via email"
        
        
        let alert = UIAlertController(title: titleStr, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let placeholderStr =  "OTP"
        
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = placeholderStr
            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (_) -> Void in
            
        })
        
        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (_) -> Void in
            let textfield = alert.textFields!.first
             let textField = alert.textFields![0]
            if (textfield?.text!.contains(self.userOtp!))! {
                if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "UpdatePasswordViewController") as? UpdatePasswordViewController
                {
                    
                    
                    vc.code = self.userOtp
                    vc.email = self.email.text
                    self.navigationController?.pushViewController(vc, animated: true)
                    // self.present(vc, animated: true, completion: nil)
                }
                
            }
            else {
                self.DisplayMessage(userMessage: "Invalid OTP", title: "Error")
            }
            
            
            //Do what you want with the textfield!
        })
        
        alert.addAction(cancel)
        alert.addAction(action)
        
        self.actionToEnable = action
        action.isEnabled = false
        self.present(alert, animated: true, completion: nil)
    }
    @objc func textChanged(sender:UITextField) {
        self.actionToEnable?.isEnabled = (sender.text! != "")
    }
    func customDisplay(userMessage:String , title: String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: userMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default){(
                ACTION:UIAlertAction!) in
                //self.emptyAllTextFields()
                //                if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
                //                {
                //
                //                    self.navigationController?.pushViewController(vc, animated: true)
                //                }
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
    private func validateContactUsFields()-> Bool {
        
        if !HelperFuntions.validateRequiredField(email.text!){
            
            HelperFuntions.showAlert("Error", withMessage: "Please enter email")
            return false
        }
        
        return true
    }
    
    private func ForgotPassword() {
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.forgotPasswords)")
        let postString = ["email": email.text!]  as [String : Any]
        let MyHeader = ["content-type": "application/json"]
        
        Alamofire.request(url!, method: .post, parameters: postString, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
            DispatchQueue.main.async {
                
                
                switch responseJSON.result{
                    
                case .success(let data):
                    
                    var statusCode:Int = 0
                    if responseJSON.result.value != nil{
                        
                        statusCode = (responseJSON.response?.statusCode)!
                        print("...HTTP code: \(statusCode)")
                    }
                    
                    
                    print(data)
                    HUD.hide()
                    let recievedCode = data as! NSDictionary
                    
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let status = req.value(forKey: "status") as! Int
                    let result = req.value(forKey: "result") as! Bool
                    let message = req.value(forKey: "msg") as! String
                    self.userOtp = recievedCode.value(forKey: "opt") as? String
                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1 && result == true {
                            self.ValidateOTP()
                        }
                        else if statusCode == 200 && status == 2 && result == false {
                            self.customDisplay(userMessage: message, title: "Info")
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
    
    func DisplayNet(userMessage:String , title: String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: userMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default){(
                ACTION:UIAlertAction!) in
       
                
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }

}
