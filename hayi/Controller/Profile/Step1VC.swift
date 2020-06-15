//
//  Step1VC.swift
//  hayi-ios2
//
//  Created by Mohsin on 25/09/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import iOSDropDown
import Alamofire
import PKHUD

struct Neighbour {
    var id : Int?
    var name : String?
}
struct subCommuni {
    var id : Int?
    var name : String?
}
class Step1VC: UIViewController {
    
    @IBOutlet weak var subComunityContainer: UIView!
    var isLoaded:Bool = false
    var yourArray = [Neighbour]()
    var stringArray = [String]()
    
    var idarray = [Int]()
    var stringArray2 = [String]()
    var idarray2 = [Int]()
    @IBOutlet weak var neighbourhood: DropDown!
    var isSecond : Bool?
   
    @IBOutlet weak var subCommon: DropDown!
    
    @IBOutlet weak var nextBtn: RoundButton!
    
    var boundries  = [[String:Any]]()
    var subCommun = [[String:Any]]()
    var isFirst : Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        neighbourhood.delegate = self
        subCommon.delegate = self
        nextBtn.isEnabled = false
        nextBtn.alpha = 0.25
        isFirst = true
        isSecond = false
        if Connectivity.isConnectedToInternet(){
        getNeighbourhood()
        }else{
            self.DisplayMessage(userMessage: internetNot, title: "info")
        }
        
        //Its Id Values and its optional
        
        // Image Array its optional
        neighbourhood.listWillAppear {
            if !self.isLoaded {
                if Connectivity.isConnectedToInternet(){
                    self.getNeighbourhood()
                }else{
                    self.DisplayMessage(userMessage: internetNot, title: "info")
                }
            }
        }
        
        // The the Closure returns Selected Index and String
        neighbourhood.didSelect{(selectedText , index ,id) in
            
            if selectedText == "Can't find your neighbourhood?" {
                guard let url = URL(string: "https://www.hayi.app/add-a-community") else { return }
                UIApplication.shared.open(url)
            }else {
                AppManager.neighbourHoodId = id
                AppManager.neighbourHoodName =  self.stringArray[index]
                self.nextBtn.isEnabled = true
                self.nextBtn.alpha = 1
                if Connectivity.isConnectedToInternet(){
                self.getSubCommun(id: id)
                }else {
                    self.DisplayMessage(userMessage: internetNot, title: "Info")
                }
            }
            
        }
        subCommon.didSelect{(selectedText , index ,id) in
            print( "Selected String: \(selectedText) \n index: \(self.idarray2[index]) id :\(id)")
            AppManager.subcommunID = id

           // self.getSubCommun(id: id)
            
        }
        // Do any additional setup after loading the view.
        
        let yourBackImage = UIImage(named: "Back")
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        
        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.title = ""

        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.backBarButtonItem?.title = ""
       // self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
       // self.tabBarController?.tabBar.isHidden = false
        self.navigationItem.backBarButtonItem?.title = ""
        
    }
    
    @IBAction func actionPrivacy(_ sender: UIButton) {
        guard let url = URL(string: "https://www.hayi.app/privacy-policy") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func actionTermsAndConditions(_ sender: UIButton) {
        guard let url = URL(string: "https://www.hayi.app/terms-conditions") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func actionCommunityGuideLines(_ sender: UIButton) {
        guard let url = URL(string: "https://www.hayi.app/community-guidelines") else { return }
        UIApplication.shared.open(url)
    }
    
    private func getNeighbourhood(){
        
        
        DispatchQueue.main.async {
        
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        }
        let url = URL(string:"\(HelperFuntions.getNeighbour)")
        // let postString = ["neighbourhoodId": 1] as [String : Any]
        let MyHeader = ["content-type": "application/json"]
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
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
                    //                    self.InvoiceListarray  = recievedCode.value(forKeyPath: "InvoiceList") as? NSArray
                    //self.boundries = recievedCode.value(forKey: "neighbourhoods") as! NSDictionary
                    self.boundries = recievedCode["neighbourhoods"] as! [[String:Any]]
                    
                    
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let status = req.value(forKey: "status") as! Int
                    
                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1{
                            for i in 0..<self.boundries.count {
                                let dic = self.boundries[i] as NSDictionary
                                let name =  dic["name"] as? String
                                let id =  dic["neighbourhoodsId"] as? Int
                                
                                let obj = Neighbour(id: id, name: name)
                                self.stringArray.append(name!)
                                self.idarray.append(id!)
                                self.yourArray.append(obj)
                                print(self.yourArray.count)
                                
                                
                            }
                            
                            self.stringArray.append("Can't find your neighbourhood?")
                            self.idarray.append(0)
                            
                            self.neighbourhood.optionArray = []
                            self.neighbourhood.optionIds = []
                            self.neighbourhood.optionArray = self.stringArray
                            self.neighbourhood.optionIds = self.idarray
                            self.neighbourhood.rowBackgroundColor = .white
                            self.neighbourhood.selectedRowColor = .white
                            self.neighbourhood.checkMarkEnabled = false
                            self.neighbourhood.isSearchEnable = false
                            self.isLoaded = true
                            
                        }
                        
                        
                    }
                    if statusCode == 401{
                        self.isLoaded = false
                    }
                case .failure(let error):
                    print(error)
                    HUD.hide()
                    self.isLoaded = false
                }
                
                
                
                
            }
            
        }
    }
    
    private func getSubCommun(id : Int){
        
        
        self.stringArray2.removeAll()
        self.idarray2.removeAll()
        self.subCommon.text = ""
        self.subComunityContainer.isHidden = true
        
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.subCommun)?neighbourhoodId=\(id)")
        // let postString = ["neighbourhoodId": 1] as [String : Any]
        let MyHeader = ["content-type": "application/json"]
        //print(url)
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
            DispatchQueue.main.async {
                
                HUD.hide()
                switch responseJSON.result{
                    
                case .success(let data):
                    var statusCode:Int = 0
                    if responseJSON.result.value != nil{
                        
                        statusCode = (responseJSON.response?.statusCode)!
                        print("...HTTP code: \(statusCode)")
                    }
                    print(" data \(data)")
                    
                    
                    
                    let recievedCode = data as! NSDictionary
                    //                    self.InvoiceListarray  = recievedCode.value(forKeyPath: "InvoiceList") as? NSArray
                    //self.boundries = recievedCode.value(forKey: "neighbourhoods") as! NSDictionary
                    
                    
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let status = req.value(forKey: "status") as! Int
                    self.subCommun = recievedCode["subCommunities"] as! [[String:Any]]
                    
                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1{
                            for i in 0..<self.subCommun.count {
                                let dic = self.subCommun[i] as NSDictionary
                                let name =  dic["name"] as? String
                                let id =  dic["subCommunitiesID"] as? Int
                                
                                self.stringArray2.append(name!)
                                self.idarray2.append(id!)
                                //print(self.dic.count)
                                
                                
                            }
                            if self.subCommun.count == 1 {
                                
                                self.subComunityContainer.isHidden = true
                                
                                AppManager.subcommunID = self.idarray2[0]
                                
                                self.subCommon.text =  self.stringArray2[0]
                                
                            }
                            else {
                                
                                self.subComunityContainer.isHidden = false
                                AppManager.subcommunID =  nil
                            self.subCommon.optionArray = self.stringArray2
                            self.subCommon.optionIds = self.idarray2
                            self.subCommon.rowBackgroundColor = .white
                            self.subCommon.selectedRowColor = .white
                            self.subCommon.checkMarkEnabled = false
                            self.subCommon.isSearchEnable = false

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


    @IBAction func nextBtn(_ sender: Any) {
        if neighbourhood.text! != "" && subCommon.text! != ""  {
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

            let  VC = self.storyboard?.instantiateViewController(withIdentifier: "Step2VC") as? Step2VC
            if let vc = storyboard.instantiateViewController(withIdentifier: "Step2VC") as? Step2VC
            {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            //self.performSegue(withIdentifier: "goNext", sender: self)
        }
    }
}

extension Step1VC : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField)  {
        if textField == neighbourhood{
            isSecond = true
            self.subCommon.isUserInteractionEnabled = true
            
            
        }else if textField == subCommon {
            
            if !isSecond!{
                
                self.DisplayMessage(userMessage: "Please first select Neighbourhood", title: "Alert")
                //self.subCommon.isUserInteractionEnabled = false
                self.subCommon.resignFirstResponder()
                
            }else{
                //  nextBtn.isEnabled = true
                //nextBtn.alpha = 1
            }
        }
        
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (neighbourhood.text!.isEmpty) && (subCommon.text!.isEmpty) {
            nextBtn.isEnabled = false
            nextBtn.alpha = 0.5
        }else{
            nextBtn.isEnabled = true
            nextBtn.alpha = 1
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if !text.isEmpty{
            nextBtn?.isUserInteractionEnabled = true
            nextBtn?.alpha = 1.0
        } else {
            nextBtn?.isUserInteractionEnabled = false
            nextBtn?.alpha = 0.5
        }
        return true
        
        
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
}

