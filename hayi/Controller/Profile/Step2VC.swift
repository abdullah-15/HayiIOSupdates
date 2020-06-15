//
//  Step2VC.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 18/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit

class Step2VC: UIViewController  , RadioButtonGroupDelegate {
   
    
    
    @IBOutlet weak var Female: PVRadioButton!
    
    @IBOutlet weak var Male: PVRadioButton!
    
    @IBOutlet weak var fName: UITextField!
    
    @IBOutlet weak var lName: UITextField!
    
    var radioButtonController: SSRadioButtonsController?

    @IBOutlet weak var other: PVRadioButton!
    var radioButtonGroup: PVRadioButtonGroup!

    @IBOutlet weak var nextBtn: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        radioButtonGroup = PVRadioButtonGroup()
        radioButtonGroup.delegate = self
        radioButtonGroup.appendToRadioGroup(radioButtons: [Female,Male, other])
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true

       // Female.isSelected = true
        //AppManager.courseID = 1
        self.fName.delegate = self
        self.lName.delegate = self
        self.nextBtn.isEnabled = false
        self.nextBtn.alpha = 0.25
        
        let yourBackImage = UIImage(named: "Back")
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        
        // Do any additional setup after loading the view.
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(NextBtn(_:)))

    }
  
//  override func viewWillAppear(_ animated: Bool) {
//    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//  }
    func didSelectButton(selectedButton: UIButton?) {
       // NSLog(" \(String(describing: selectedButton?.tag))" )
        AppManager.courseID = selectedButton?.tag
        print(AppManager.courseID!)

    }
    func radioButtonClicked(button: PVRadioButton) {
         print(button.titleLabel?.text ?? "")
        if button.titleLabel?.text! == "Female" {
            AppManager.courseID = 1

        }else if button.titleLabel?.text! == "Male"{
            AppManager.courseID = 2

        }else{
            AppManager.courseID = 3
        }
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
         self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.tabBarController?.tabBar.isHidden = true

    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    @IBAction func NextBtn(_ sender: Any) {
        if validateContactUsFields() {
            
            
            AppManager.firstName = fName.text!
            AppManager.familyName = lName.text!
            
            
            if AppManager.courseID != nil {
                if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "Step3VC") as?
                    Step3VC
                {
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
           
            
            
            
            print("Successfuly Saved!!")
            //self.performSegue(withIdentifier: "homescreen", sender: self)

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
    private func validateContactUsFields()-> Bool {
        
        if !HelperFuntions.validateRequiredField(fName.text!){
            
            HelperFuntions.showAlert("Erorr", withMessage: "Please enter first name.")
            return false
        }
        
        if !HelperFuntions.validateRequiredField(lName.text!){
            
            HelperFuntions.showAlert("Error", withMessage: "Please enter family name.")
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
    
}
extension Step2VC : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField)  {
        if textField == fName{
            if !fName.text!.isEmpty{
                
            }else{
               // nextBtn.isEnabled = true
                //nextBtn.alpha = 1
            }
          
            
            
        }else if textField == lName {
            if !lName.text!.isEmpty{
               
            }else{
                nextBtn.isEnabled = true
                nextBtn.alpha = 1
            }
        }
        
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (fName.text!.isEmpty) && (lName.text!.isEmpty) {
            nextBtn.isEnabled = false
            nextBtn.alpha = 0.5
        }else{
            nextBtn.isEnabled = true
            nextBtn.alpha = 1
        }
    }
}
