//
//  MakaniViewController.swift
//  hayi-ios2
//
//  Created by Mohsin on 23/09/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class MakaniViewController: UIViewController  , UITextFieldDelegate{
    
    @IBOutlet weak var isNext: RoundButton!
    
    @IBOutlet weak var isNeighbourhood: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isNext.alpha = 0.25
        self.isNext.isEnabled = false
        self.isNeighbourhood.delegate = self
        
        
        let yourBackImage = UIImage(named: "Back")
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.title = "Verify Makani Number"

        // Do any additional setup after loading the view.
    }
    

    @IBAction func NextBtn(_ sender: Any) {
        if validateContactUsFields() {
            if isNeighbourhood.text?.count == 10 {
                let isvalue  = Int(isNeighbourhood.text!)
                
                self.posMakaniNumber(number: isvalue!)
            }else{
                self.DisplayMessage(userMessage: "Please Enter only 10 Digits", title: "info")
                self.isNext.alpha = 0.25
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if (isNeighbourhood.text!.isEmpty)  {
//            isNext.isEnabled = false
//            isNext.alpha = 0.5
//        }else{
//            isNext.isEnabled = true
//            isNext.alpha = 1
//        }
//    }
    @IBAction func back(_ sender: Any) {
       //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    private func validateContactUsFields()-> Bool {
        
        if !HelperFuntions.validateRequiredField(isNeighbourhood.text!){
            
            HelperFuntions.showAlert("Erorr", withMessage: "Please enter  10 digit code.")
            return false
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == isNeighbourhood{
            if isNeighbourhood.text?.count == 10 {
                 self.isNext.alpha = 1
                self.isNext.isEnabled = true
                self.isNeighbourhood.resignFirstResponder()
            }else{
                
            }
           
            
        }
    }
    
    private func posMakaniNumber(number : Int){
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.makaninumber)")
        let postString = ["userId" : UserDefaults.standard
            .value(forKey: KeyUnApproved)!,
                          "makaniNumber" : number,
            ] as [String : Any]
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
                    
                    
                    let status = recievedCode.value(forKey: "status") as! Int
                    let result = recievedCode.value(forKey: "result") as! Bool
                    let message =  recievedCode.value(forKey: "msg") as! String
                    
                    
                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1 && result == true{
                            
                           // self.custom(userMessage: message, title: "user info")
                            
                            if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "FinalStepVC") as? FinalStepVC
                            {
                                
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            
                        }else if status == 200 && status == 2 && result == false {
                            self.DisplayMessage(userMessage: message, title: "user info")
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
    func custom(userMessage:String , title: String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: userMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default){(
                ACTION:UIAlertAction!) in
                //self.emptyAllTextFields()
                if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "FinalStepVC") as? FinalStepVC
                {
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
       // self.navigationController?.isNavigationBarHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.isNavigationBarHidden = true
        
    }
    
}
