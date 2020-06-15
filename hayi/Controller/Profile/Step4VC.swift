//
//  Step3VC.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 18/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import GoogleMaps
import PKHUD
import Alamofire

class Step4VC: UIViewController  , CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    
    @IBOutlet weak var nextBtns: RoundButton!
    @IBOutlet weak var text1: UITextField!
    @IBOutlet weak var text2: UITextField!
    @IBOutlet weak var text3: UITextField!
    @IBOutlet weak var text4: UITextField!
    @IBOutlet weak var text5: UITextField!
    @IBOutlet weak var text6: UITextField!
    @IBOutlet weak var text7: UITextField!
    @IBOutlet weak var text8: UITextField!
    @IBOutlet weak var text9: UITextField!
    @IBOutlet weak var text10: UITextField!
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var showCross: UIButton!
    
    
    @IBOutlet weak var makaniAlert: UIView!
    
    @IBOutlet weak var mapAlert: UIView!
    

  var list = ["By location sharing" , "By makani number" , "By documents"]
  

    @IBOutlet weak var showMap: GMSMapView!
    
  
    override func viewDidLoad() {
       super.viewDidLoad()
        
        let yourBackImage = UIImage(named: "Back")
        self.tabBarController?.tabBar.isHidden = true

        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        
        
      //  let showMap = GMSMapView.mapWithFrame(CGRectZero, camera: GMSCameraPosition, camera: )
        self.showMap?.isMyLocationEnabled = true
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
      listTable.registerTableCellsAndHeaders(cells: ["simpleCell"])
      listTable.tableFooterView = UIView()
       self.title = "Verifications"
        self.showMap.bringSubviewToFront(showCross)
        self.nextBtns.isEnabled = false
        //text1.becomeFirstResponder()
        
        self.showMap.delegate = self
        text1.delegate = self
        text2.delegate = self
        text3.delegate = self
        text4.delegate = self
        text5.delegate = self
        text6.delegate = self
        text7.delegate = self
        text8.delegate = self
        text9.delegate = self
        text10.delegate = self
        

        text1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        text2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        text3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        text4.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        text5.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        text6.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        text7.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        text8.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        text9.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        text10.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
    }

   @objc func textFieldDidChange(textField: UITextField){
        
        let text = textField.text
        
        if text?.utf16.count==1{
            switch textField{
            case text1:
                text2.becomeFirstResponder()
            case text2:
                text3.becomeFirstResponder()
            case text3:
                text4.becomeFirstResponder()
            case text4:
                text5.becomeFirstResponder()
            case text5:
                text6.becomeFirstResponder()
            case text6:
                text7.becomeFirstResponder()
            case text7:
                text8.becomeFirstResponder()
            case text8:
                text9.becomeFirstResponder()
            case text9:
                text10.becomeFirstResponder()
            case text10:
                text10.resignFirstResponder()
            default:
                break
            }
        }else{
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {


        let location = locations.last

        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 20.0)

        self.showMap?.animate(to: camera)

        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()

        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways){
            //let marker = GMSMarker()
            currentLocation = locationManager.location

           // marker.position = CLLocationCoordinate2D(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)

           // marker.map = self.showMap
            print("longitude \(currentLocation!.coordinate.longitude)")
            print("latitude \(currentLocation!.coordinate.latitude)")


        }

    }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    self.tabBarController?.tabBar.isHidden = true

  }
    
    @IBAction func hide(_ sender: Any) {
        //mapalert
        mapAlert.alpha = 0
        self.showMap.clear()
    }
    
    
    @IBAction func save(_ sender: Any) {
        makaniAlert.alpha = 0
        self.nextBtns.isEnabled = true

        if validateContactUsFields(){
            let number:Int = Int( "\(text1.text!)\(text2.text!)\(text3.text!)\(text4.text!)\(text5.text!)\(text6.text!)\(text7.text!)\(text8.text!)\(text9.text!)\(text10.text!)")!
            
            posMakaniNumber(number: number)
            
        }
        
    }
    
    
   
    
    @IBAction func cross1(_ sender: Any) {
        makaniAlert.alpha = 0
        self.text1.text = ""
        self.text2.text = ""

        self.text3.text = ""
        self.text4.text = ""
        self.text5.text = ""
        self.text6.text = ""
        self.text7.text = ""
        self.text8.text = ""
        self.text9.text = ""
        self.text10.text = ""




        
    }
    
    @IBAction func selectMap(_ sender: Any) {
        mapAlert.alpha = 0
        self.nextBtns.isEnabled = true
        self.locationManager.startUpdatingLocation()
        
        self.showMap.animate(toZoom: 15)

        postLocation()
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        self.nextBtns.isEnabled = false
        if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "FinalStepVC") as? FinalStepVC
        {
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func postLocation(){
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.location)")
        let postString = ["latitude": currentLocation!.coordinate.latitude,
                          "longitude" : currentLocation!.coordinate.longitude,
                          "userId" : UserDefaults.standard
                            .value(forKey: "userID")!] as [String : Any]
        let MyHeader = ["content-type": "application/json"]
        
        print(postString)
        
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
                    print("location data \(data)")
                    
                    
                    
                    let recievedCode = data as! NSDictionary
                    //                    self.InvoiceListarray  = recievedCode.value(forKeyPath: "InvoiceList") as? NSArray
                    //self.boundries = recievedCode.value(forKey: "neighbourhoods") as! NSDictionary
                   // self.boundries = recievedCode["neighbourhoods"] as! [[String:Any]]
                    
                    
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let status = req.value(forKey: "status") as! Int
                    let result = req.value(forKey: "result") as! Bool

                    
//
//
//                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200  {
                            let msg = req.value(forKey: "msg") as! String

                            if status == 1 && result == true  {
                                self.DisplayMessage(userMessage: msg, title: "Info")
                            }else if status == 2 && result == false{
                                self.DisplayMessage(userMessage: msg, title: "Info")
                                
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
    
    private func posMakaniNumber(number : Int){
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.makaninumber)")
        let postString = ["userId" : UserDefaults.standard.string(forKey: KeyUserId)!,
                          "makaniNumber" : currentLocation!.coordinate.longitude,
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
                            
                            
                            if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "FinalStepVC") as? FinalStepVC
                            {
                             
                                vc.isVerified = true
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
    private func validateContactUsFields()-> Bool {
        
        if !HelperFuntions.validateRequiredField(text1.text!){
            
            HelperFuntions.showAlert("Erorr", withMessage: "Please enter  10 digit code.")
            return false
        }
        
        if !HelperFuntions.validateRequiredField(text2.text!){
            
            HelperFuntions.showAlert("Error", withMessage: "Please enter  10 digit code.")
            return false
        }
        if !HelperFuntions.validateRequiredField(text3.text!){
            
            HelperFuntions.showAlert("Error", withMessage: "Please enter  10 digit code.")
            return false
        }
        if !HelperFuntions.validateRequiredField(text4.text!){
            
            HelperFuntions.showAlert("Error", withMessage: "Please enter  10 digit code.")
            return false
        }
        if !HelperFuntions.validateRequiredField(text5.text!){
            
            HelperFuntions.showAlert("Error", withMessage: "Please enter  10 digit code.")
            return false
        }
        if !HelperFuntions.validateRequiredField(text6.text!){
            
            HelperFuntions.showAlert("Error", withMessage: "Please enter  10 digit code.")
            return false
        }
        if !HelperFuntions.validateRequiredField(text7.text!){
            
            HelperFuntions.showAlert("Error", withMessage: "Please enter  10 digit code.")
            return false
        }
        if !HelperFuntions.validateRequiredField(text8.text!){
            
            HelperFuntions.showAlert("Error", withMessage: "Please enter  10 digit code.")
            return false
        }
        if !HelperFuntions.validateRequiredField(text9.text!){
            
            HelperFuntions.showAlert("Error", withMessage: "Please enter  10 digit code.")
            return false
        }
        if !HelperFuntions.validateRequiredField(text10.text!){
            
            HelperFuntions.showAlert("Error", withMessage: "Please enter  10 digit code.")
            return false
        }
        
        return true
    }

    @IBAction func backBtn(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }
    
}




extension Step4VC: UITableViewDelegate , UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return list.count
  }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //mapAlert.alpha = 1
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowMapViewController") as! ShowMapViewController
           // self.present(vc, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 1 {
           // makaniAlert.alpha = 1
            //MakaniViewController
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MakaniViewController") as! MakaniViewController
            //self.present(vc, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc, animated: true)

        }else if indexPath.row == 2{
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ImageUploadViewController") as! ImageUploadViewController
            //self.present(vc, animated: true, completion: nil)
            
            self.navigationController?.pushViewController(vc, animated: true)

        }
    }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    
    let cellstatic = listTable.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! simpleCell
    cellstatic.configureCell(title: self.list[indexPath.row])
    return cellstatic
    
    
    
    
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
}

extension Step4VC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
}
extension Step4VC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        // Custom logic here
        self.locationManager.startUpdatingLocation()
        
        currentLocation = locationManager.location

        print("longitude \(currentLocation!.coordinate.longitude)")
        print("latitude \(currentLocation!.coordinate.latitude)")
       

        let marker = GMSMarker()
        marker.position = coordinate
    
        marker.snippet = ""
        marker.map = mapView
         self.showMap.animate(toZoom: 15)
    }
}
