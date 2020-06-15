//
//  ShowMapViewController.swift
//  hayi-ios2
//
//  Created by Mohsin on 23/09/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import GoogleMaps
import PKHUD
import Alamofire
import GooglePlaces

class ShowMapViewController: UIViewController , CLLocationManagerDelegate{
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    
    @IBOutlet weak var isNextBtn: RoundButton!

    @IBOutlet weak var showMap: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
       // addshadow(view: searchbarview)
        
        let yourBackImage = UIImage(named: "Back")
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.title = "Verify Location"

        //self.showMap.bringSubviewToFront(isNextBtn)
        self.showMap?.isMyLocationEnabled = true
        self.locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        
        self.locationManager.startUpdatingLocation()
           showMap.settings.myLocationButton = true
        
        self.showMap.animate(toZoom: 12)
        
        showMap.padding = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 10)
        
        // Do any additional setup after loading the view.
    }
    
    func addshadow(view : UIView)
    {
        
        view.setNeedsUpdateConstraints()
        view.layoutIfNeeded()
        view.updateConstraints()
        view.layer.cornerRadius = view.frame.size.height/2
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func mapNext(_ sender: Any) {
        
    
        let locStatus = CLLocationManager.authorizationStatus()
        switch locStatus {
           case .notDetermined:
              locationManager.requestWhenInUseAuthorization()
           return
           case .denied, .restricted:
              let alert = UIAlertController(title: "Location Services are disabled", message: "Please enable Location Services in your Settings", preferredStyle: .alert)
              let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
              alert.addAction(okAction)
              present(alert, animated: true, completion: nil)
           return
           case .authorizedAlways, .authorizedWhenInUse:
               postLocation()
           break
        }
    }
    private func postLocation(){
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        
        let userId = UserDefaults.standard.value(forKey: KeyUnApproved) as! Int
        
        let url = URL(string:"\(HelperFuntions.location)")
        let postString = ["latitude": currentLocation!.coordinate.latitude,
                          "longitude" : currentLocation!.coordinate.longitude,
                          "userId" : userId] as [String : Any]
        //to verify user for testing
//        let postString = ["latitude": "25.048899",
//        "longitude" : "55.261118",
//        "userId" : userId] as [String : Any]
        
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
                    
                    let isExists = recievedCode.value(forKey: "isExist") as! Bool
                    
                    //
                    //
                    //                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200  {
                            let msg = req.value(forKey: "msg") as! String
                            
                            if status == 1 && result == true  {
                                
                                if isExists
                                {
                                    //self.custom(userMessage: msg, title: "Info")
                                    if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "FinalStepVC") as? FinalStepVC
                                    {
                                     
                                        vc.isVerified = true
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }
                                else {
                                        self.DisplayMessage(userMessage: "Your location is not in the neighbourhood", title: "Info")
                                }
                            } else if status == 2 && result == false {
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
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
       // self.dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 12.0)
        
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
    
    @IBAction func textFieldTab(_ sender: Any) {
        
        self.view.endEditing(true)

        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        //self.navigationController?.isNavigationBarHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // self.navigationController?.isNavigationBarHidden = true
        
    }

}
extension ShowMapViewController :GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Get the place name from 'GMSAutocompleteViewController'
        // Then display the name in textField
        
        print(place.coordinate.latitude)
        print(place.coordinate.longitude)
        // Dismiss the GMSAutocompleteViewController when something is selected
        dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
}
