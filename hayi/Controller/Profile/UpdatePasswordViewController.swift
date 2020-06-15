//
//  UpdatePasswordViewController.swift
//  hayi-ios2
//
//  Created by Mohsin on 23/09/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class UpdatePasswordViewController: UIViewController {
    var code : String?
    @IBOutlet weak var isnext: RoundButton!
    var email: String?
    
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.isnext.isEnabled = false
        // Do any additional setup after loading the view.
        
        let yourBackImage = UIImage(named: "Back")
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.title = "Update Password"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    private func validateContactUsFields()-> Bool {
        
        if !HelperFuntions.validateRequiredField(password.text!){
            
            HelperFuntions.showAlert("Error", withMessage: "Please enter password.")
            return false
        }
        return true
    }
    
    func DisplayMessage(userMessage:String , title: String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: userMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default){(
                ACTION:UIAlertAction!) in
                //self.emptyAllTextFields()
                if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
                {

                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    func customDisplay(userMessage:String , title: String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: userMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default){(
                ACTION:UIAlertAction!) in
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
    
    @IBAction func nextBtn(_ sender: Any) {
    
        
        
        if validateContactUsFields() {
            if(!isValidPassword(testStr: password.text!)){
                self.customDisplay(userMessage: "Atleast 1 UperCase, 1 Numeric & Minimum Length is 6", title: "Invalid Passord")
                return
                
            }
            
            else{
                
                if(password.text! != confirmPassword.text!) {
                    
                    self.customDisplay(userMessage: "Confirm password does not match", title: "Invalid Passord")
                }
                
                if Connectivity.isConnectedToInternet() {
                    self.updatePassword()
                }
                else {
                        self.customDisplay(userMessage: internetNot, title: "Info")
                    }
                }
        }
    }
    
    private func updatePassword(){
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.updatePassword)")
        let postString = ["email": email! ,
                          "password" : password.text!]  as [String : Any]
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
                    
                    //let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let status = recievedCode.value(forKey: "status") as! Int
                    let result = recievedCode.value(forKey: "result") as! Bool
                    let message = recievedCode.value(forKey: "msg") as! String

                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1 && result == true{
                           
                          
                            self.DisplayMessage(userMessage: "Successfully Updated", title: "Alert")
                            
                        }else if statusCode == 200 && status == 2 && result == false {
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

}
