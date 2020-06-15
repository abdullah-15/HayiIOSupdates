//
//  verifyAddressMapVC.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 30/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps
import Alamofire
import PKHUD


class verifyAddressMapVC: UIViewController , CLLocationManagerDelegate , GMSMapViewDelegate  {
    
    @IBOutlet weak var shwomap: UIView!
    
    @IBOutlet weak var myShowMap: GMSMapView!
    
    var locationManager = CLLocationManager()
    var address : NSArray = NSArray()
    var subCommunites : NSArray = NSArray()
    var cShape : NSArray = NSArray()
    var polygoninside : GMSPolygon?
    
    @IBOutlet weak var NeighbourHoodName: UILabel!
    @IBOutlet weak var ZoomIn: UIButton!
    
    @IBOutlet weak var ZoomOut: UIButton!
    
    @IBOutlet weak var messageLabel: UILabel!
    var zoom: Float = 15
    var bounds: GMSCoordinateBounds?
    var check : GMSMapView?
    var ischeck: Bool = false
    var iscounter : Float = 0
    var userPolyGon = [GMSPolygon]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        self.myShowMap.bringSubviewToFront(ZoomIn);
        self.myShowMap.bringSubviewToFront(ZoomOut);
        self.locationManager.delegate = self
        check?.delegate = self
        self.myShowMap.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        //backBarButtonItem = UIImage(named: "back")
        let backImage = UIImage.init(named: "Back")
        let backImageView = UIImageView.init(image: backImage)
        backImageView.frame = CGRect(x:0.0,y:0.0, width:20,height:20.0)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.goBackButton))
        backImageView.addGestureRecognizer(tap)
        
        let backItem = UIBarButtonItem.init(customView: backImageView)
        navigationItem.leftBarButtonItems =  [backItem]
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(goBackButton))
        
        self.NeighbourHoodName.text =  AppManager.neighbourHoodName
        
        
        //    let camera = GMSCameraPosition.camera(withLatitude: 25.05975,
        //                                          longitude: 55.29929,
        //                                          zoom: 12)
        //    self.myShowMap.camera =  camera
        self.myShowMap.animate(toZoom: 12)
        
        myShowMap.settings.zoomGestures = true
        self.myShowMap.settings.scrollGestures =  true
                    
            getMembers()
            getUserData()
           // getSubCommnity()

    }
    @objc func goBackButton() {
                
    }
    
    private func getUserData(){
        //HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.getNeighbourHoodPolygone)")
        let postString = ["neighourhoodId": AppManager.neighbourHoodId] as [String : Any]
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
                    //                    self.InvoiceListarray  = recievedCode.value(forKeyPath: "InvoiceList") as? NSArray
                    self.address = recievedCode.value(forKey: "coordinates") as! NSArray
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let status = req.value(forKey: "status") as! Int
                    AppManager.invoicedata = self.address
                    
                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1{
                            let dic = self.address[0] as! NSDictionary
                            let latitude = dic["latitude"] as! Double
                            let longitude = dic["longitude"] as! Double
                            let camera = GMSCameraPosition.camera(withLatitude: latitude,
                                                                  longitude: longitude,
                                                                  zoom: 12)
                            self.myShowMap.camera =  camera
                            
                            var bounds = GMSCoordinateBounds()

                            let path = GMSMutablePath()
                            for i in 0..<self.address.count {
                                let dic = self.address[i] as! NSDictionary
                                let latitude = dic["latitude"] as! Double
                                let longitude = dic["longitude"] as! Double
                                
                                print("latitude \(latitude) and longitude \(longitude)")
                                
                                bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                
                                path.add(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                
                                
                                
                            }
                            
                            
                            
                            
                            
                            let polygon = GMSPolygon(path: path)
                            polygon.fillColor = UIColor(hexString: "#42c4c0" , alpha: 0.5)
                            polygon.strokeColor = .red
                            polygon.strokeWidth = 1.0
                            //  polygon.fillColor = UIColor(hexString: "#DC143C")
                            polygon.map = self.myShowMap
                            
                            self.myShowMap.animate(with:GMSCameraUpdate.fit(bounds,withPadding: 15.0))
                            
                            //                            DispatchQueue.main.async
                            //                                {
                            //                                    if self.myShowMap != nil
                            //                                    {
                            //                                        //self.bounds = GMSCoordinateBounds(path: path)
                            //                                        self.myShowMap!.animate(toZoom: 12)
                            //                                    }
                            //                            }
                            
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
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    
    @IBAction func Registered(_ sender: Any) {
        
        if let vc = HelperFuntions.storyBoard.instantiateViewController(withIdentifier: "Step4VC") as? Step4VC
        {
            
            self.navigationController?.pushViewController(vc, animated: true)
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
    
    func customMessage(userMessage:String , title: String) -> Void {
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
    
    private func getSubCommnity(){
        //HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.getSubCommunites)\(AppManager.neighbourHoodId)") 
        let MyHeader = ["content-type": "application/json"]
        
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
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
                    //                    self.InvoiceListarray  = recievedCode.value(forKeyPath: "InvoiceList") as? NSArray
                    self.subCommunites = recievedCode.value(forKey: "subCommunities") as! NSArray
                    self.cShape =  self.subCommunites.value(forKey: "scShapes") as! NSArray
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let status = req.value(forKey: "status") as! Int
                    
                    
                    
                    print("Successfuly fetch subcommunity data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1{
                            
                            
                            
                        }
                        
                        
                    }
                    if statusCode == 401{
                        
                    }
                case .failure(let error):
                    print(error)
                    //self.DisplayMessage(userMessage: "Erorr in Api", title: "Error")
                    HUD.hide()
                }
                
                
                
                
            }
            
        }
    }
    
     func getMembers() {
        
        let neighbourHoodId = AppManager.neighbourHoodId
        
        
        let url = URL(string:"\(HelperFuntions.GetNoofMembersinNeighbourhood)?id=\(neighbourHoodId ?? 1)")
        
        print("url is \(url!)" )
        let MyHeader = ["content-type": "application/json"]
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
            
            switch responseJSON.result{
                              
                          case .success(let data):
                              var statusCode:Int = 0
                              if responseJSON.result.value != nil{
                                  
                                  statusCode = (responseJSON.response?.statusCode)!
                                  print("...HTTP code: \(statusCode)")
                              }
                              print(data)
                              
                              let recievedCode = data as! NSDictionary
                              let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                              let status = req.value(forKey: "status") as! Int
                              
                              let members =  recievedCode.value(forKey: "members") as! Int
                              
                                  if statusCode == 200 && status == 1{
                                      
                                    self.messageLabel.text = "Only Members with a verified address can have full access to this neighbourhood. \(members) Members have already joined this neighbourhood."

                                  }
                                  
                              
                              if statusCode == 401{
                                  
                              }
                          case .failure(let error):
                              print(error)
                              //self.DisplayMessage(userMessage: "Erorr in Api", title: "Error")
                              HUD.hide()
                          }
                          
        }
    }
    
    @IBAction func ZoomIN(_ sender: Any) {
        zoom = zoom + 1
//        if ischeck == false
//        {
//            ischeck = true
//
//
//            for i in 0..<self.subCommunites.count {
//                let path = GMSMutablePath()
//
//                let dic = self.subCommunites[i] as! NSDictionary
//                let array =  dic.value(forKey: "scShapes") as! NSArray
//                for i in 0..<array.count{
//                    let data = array[i] as! NSDictionary
//                    //l//et data = dic[i] as! NSDictionary
//                    let latitude = data.value(forKey: "latitude") as! Double
//
//                    let longitude = data.value(forKey: "longitude") as! Double
//
//
//                    print("latitude \(latitude) and longitude \(longitude)")
//
//                    path.add(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
//
//                }
//                polygoninside = GMSPolygon(path: path)
//                polygoninside!.fillColor = UIColor(hexString: "#FF0000" , alpha: 0.3)
//                polygoninside!.strokeColor = UIColor(hexString: "#FF0000" , alpha: 0.5)
//                polygoninside!.strokeWidth = 1.0
//                //BB5F9A
//
//                polygoninside?.map =  self.myShowMap
//                self.userPolyGon.append(polygoninside!)
//
//            }
//
//
//        }
//        else
//        {
//            for i in 0 ..< self.userPolyGon.count {
//                let inside = self.userPolyGon[i]
//                if inside.map != nil
//                {
//                    inside.map = self.myShowMap
//                }
//
//            }
//        }
        //
        self.myShowMap.animate(toZoom: zoom)
        
    }
    
    @IBAction func ZoomOut(_ sender: Any) {
        if zoom  > 12{
            zoom = zoom - 1
            self.myShowMap.animate(toZoom: zoom)
            if ischeck == true {
                
                
                
                ischeck = false
                // self.mapview.clear()
                for i in 0 ..< self.userPolyGon.count {
                    let inside = self.userPolyGon[i]
                    inside.map = nil
                }
                
                
                
                
            }
        }
    }
    
}
