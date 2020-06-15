//
//  UserLocationsVC.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 18/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//



import UIKit
import MapKit
import CoreLocation
import GoogleMaps
import Alamofire
import PKHUD
import SwiftyJSON


class UsersLocationsVC: UIViewController , CLLocationManagerDelegate , GMSMapViewDelegate  {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet weak var btnZoom: UIButton!
    
    @IBOutlet weak var areaName: UILabel!
    
    @IBOutlet weak var neighbours: UILabel!
    
    @IBOutlet weak var zoomout: UIButton!
    @IBOutlet weak var mapview: GMSMapView!
    
    
    var locationManager = CLLocationManager()
    let marker = GMSMarker()
    let circle = GMSCircle()
    var address : NSArray = NSArray()
    var subCommunites : NSArray = NSArray()
    var cShape : NSArray = NSArray()
    var boundries : NSDictionary = NSDictionary()
    var zoom: Float = 15
    var bounds: GMSCoordinateBounds?
    var check : GMSMapView?
    var polygoninside : GMSPolygon?
    var ischeck: Bool = false
    var iscounter : Float = 0
    var userPolyGon = [GMSPolygon]()
    var subCommuntiesButton = [SubCommunitiesButton]()
    var obj : SubCommunitiesButton?
    var subcommonID:Int?
    var currentIndex : Int = 0
    
    
    @IBOutlet weak var showDialog: UIView!
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificatonArrived(_:)), name: NSNotification.Name(rawValue: "newnotification"), object: nil)
        
        self.mapview.bringSubviewToFront(btnZoom);
        self.mapview.bringSubviewToFront(showDialog);
        self.mapview.bringSubviewToFront(zoomout);
        
        
        super.viewDidLoad()
        self.locationManager.delegate = self
        check?.delegate = self
        self.mapview.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let lat  = UserDefaults.standard.value(forKey: "MapUserDefaultLatPosition") as? String
        let Lng  = UserDefaults.standard.value(forKey: "MapUserDefaultLngPosition") as? String
        
        if (lat != nil && Lng != nil) {
            
            let latd = Double(lat!) ?? 0.0000
            let longd = Double(Lng!) ?? 0.0000
           
            mapview.camera = GMSCameraPosition.camera(withLatitude: latd,longitude: longd, zoom: 15)
        }
        else {
            
             mapview.camera = GMSCameraPosition.camera(withLatitude: 25.2048,longitude: 55.2708, zoom: 15)
        }
        self.locationManager.requestWhenInUseAuthorization()
        if Connectivity.isConnectedToInternet() {
            self.mapview.isHidden = true
            getNeighbourHood()
         //   getBoundries()
            
        }else{
            self.DisplayMessage(userMessage: internetNot, title: "Info")
        }
        
        
        

        mapview.settings.zoomGestures = true
        self.mapview.settings.scrollGestures =  true
        
        self.view.sendSubviewToBack(showDialog)
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
        
        
    }
    
    
    @IBOutlet weak var leftbutton: UIButton!
    
    @IBAction func lefttouchUpInside(_ sender: Any) {
        if currentIndex == 0 && self.subCommuntiesButton.count > 0 {
            ShowNext(button:self.subCommuntiesButton[subCommuntiesButton.count-1])
            currentIndex = subCommuntiesButton.count-1
        }
        else {
            if currentIndex - 1 >= 0 && currentIndex <= self.subCommuntiesButton.count{
                currentIndex = currentIndex - 1
                ShowNext(button: self.subCommuntiesButton[currentIndex])
            }
        }
    }
    @IBAction func lefttouchOutside(_ sender: Any) {
        
        if currentIndex == 0 && self.subCommuntiesButton.count > 0 {
            ShowNext(button:self.subCommuntiesButton[subCommuntiesButton.count-1])
            currentIndex = subCommuntiesButton.count-1
        }
        else {
            if currentIndex - 1 >= 0 && currentIndex <= self.subCommuntiesButton.count{
                currentIndex = currentIndex - 1
                ShowNext(button: self.subCommuntiesButton[currentIndex])
            }
        }
    }
    
    @IBOutlet weak var rightbutton: UIButton!
    
    @IBAction func righttouchInside(_ sender: Any) {
        
        if currentIndex == 0 && self.subCommuntiesButton.count > 0 {
            currentIndex = currentIndex + 1
            ShowNext(button:self.subCommuntiesButton[1])
        }
        else {
            if currentIndex + 1 < self.subCommuntiesButton.count {
                
                currentIndex = currentIndex + 1
                ShowNext(button: self.subCommuntiesButton[currentIndex])
            }
        }
    }
    @IBAction func righttoudOutside(_ sender: Any) {
        if currentIndex == 0 && self.subCommuntiesButton.count > 0 {
            currentIndex = currentIndex + 1
            ShowNext(button:self.subCommuntiesButton[1])
        }
        else {
            if currentIndex + 1 < self.subCommuntiesButton.count {
                
                currentIndex = currentIndex + 1
                ShowNext(button: self.subCommuntiesButton[currentIndex])
            }
        }
        
    }
    
    
    
    func ShowNext(button: SubCommunitiesButton) {
        
        polygoninside?.map = nil
        
        let latitude = Double(button.latitude!)!
        
        let longitude =  Double(button.longitude!)!
        
        
        self.mapview.animate(to: GMSCameraPosition.camera(withLatitude: latitude,longitude: longitude, zoom: 15))
        
        self.showDialog.alpha = 1
        self.areaName.text = button.name!
        self.neighbours.text = "\(button.members!) Neighbours"
        self.subcommonID = button.subCommunitiesID!
        if self.subCommunites.count > 1 {
            for i in 0..<self.subCommunites.count {
            
            let path = GMSMutablePath()
            
            let dic = self.subCommunites[i] as! NSDictionary
            let id = dic.value(forKey: "subCommunitiesID") as? Int
            if subcommonID == id! {
                
                let array =  dic.value(forKey: "scShapes") as! NSArray
                for i in 0..<array.count{
                    let data = array[i] as! NSDictionary
                    //l//et data = dic[i] as! NSDictionary
                    let latitude = data.value(forKey: "latitude") as! Double
                    
                    let longitude = data.value(forKey: "longitude") as! Double
                    
                    
                    print("latitude \(latitude) and longitude \(longitude)")
                    
                    path.add(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    
                }
                polygoninside = GMSPolygon(path: path)
                polygoninside!.fillColor = UIColor(hexString: "#FF0000" , alpha: 0.3)
                polygoninside!.strokeColor = UIColor(hexString: "#FF0000" , alpha: 0.5)
                polygoninside!.strokeWidth = 1.0
                //BB5F9A
                
                polygoninside?.map =  self.mapview
                self.userPolyGon.append(polygoninside!)
                
            }
        }
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        //Write your code here...
        
        print("helo helo")
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        polygoninside?.map = nil
        
        var index = -1
        
        for a in self.subCommuntiesButton
        {
            print("\(marker.position.latitude)")
            
            self.mapview.animate(to: GMSCameraPosition.camera(withLatitude: marker.position.latitude,longitude: marker.position.longitude, zoom: 15))
            
            if a.latitude == "\(marker.position.latitude)" && a.longitude == "\(marker.position.longitude)"
            {
                if let ind = self.subCommuntiesButton.firstIndex(of:a)
                {
                    index = ind
                    currentIndex = ind
                    self.showDialog.alpha = 1
                    self.areaName.text = self.subCommuntiesButton[index].name!
                    self.neighbours.text = "\(self.subCommuntiesButton[index].members!) Neighbours"
                    self.subcommonID = self.subCommuntiesButton[index].subCommunitiesID!
                    
                    if self.subCommunites.count > 1 {
                    
                    for i in 0..<self.subCommunites.count {
                        let path = GMSMutablePath()
                        
                        let dic = self.subCommunites[i] as! NSDictionary
                        let id = dic.value(forKey: "subCommunitiesID") as? Int
                        if subcommonID == id! {
                            
                            let array =  dic.value(forKey: "scShapes") as! NSArray
                            for i in 0..<array.count{
                                let data = array[i] as! NSDictionary
                                //l//et data = dic[i] as! NSDictionary
                                let latitude = data.value(forKey: "latitude") as! Double
                                
                                let longitude = data.value(forKey: "longitude") as! Double
                                
                                
                                print("latitude \(latitude) and longitude \(longitude)")
                                
                                path.add(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                
                            }
                            polygoninside = GMSPolygon(path: path)
                            polygoninside!.fillColor = UIColor(hexString: "#FF0000" , alpha: 0.3)
                            polygoninside!.strokeColor = UIColor(hexString: "#FF0000" , alpha: 0.5)
                            polygoninside!.strokeWidth = 1.0
                            //BB5F9A
                            
                            polygoninside?.map =  self.mapview
                            self.userPolyGon.append(polygoninside!)
                            
                        }
                    }
                    }
                    
                }
            }
        }
        //you can handle zooming and camera update here
        return true
    }
    
    
    
    func setUpView() {
        
        print("In SetUpView")
    }
    
    
    
    //    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    //        // 3
    //        guard status == .authorizedWhenInUse else {
    //            return
    //        }
    //        // 4
    //        locationManager.startUpdatingLocation()
    //
    //        //5
    //        mapview.isMyLocationEnabled = true
    //        mapview.settings.myLocationButton = true
    //    }
    
    // 6
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        guard let location = locations.first else {
    //            return
    //        }
    //
    //        // 7
    //     //   mapview.camera = GMSCameraPosition(target: location.coordinate, zoom: 20, bearing: 0, viewingAngle: 0)
    ////
    ////        // 8
    //       locationManager.stopUpdatingLocation()
    //    }
    
    
    private func getNeighbourHood() {
        
        let url = URL(string:"\(HelperFuntions.getNeighbourHoodPolygone)")
        
        let postString = ["neighourhoodId": UserDefaultsManager.instance.getNeighbourHoodId()!] as [String : Any]
        
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
                    //                    self.InvoiceListarray  = recievedCode.value(forKeyPath: "InvoiceList") as? NSArray
                    self.address = recievedCode.value(forKey: "coordinates") as! NSArray
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let status = req.value(forKey: "status") as! Int
                    AppManager.invoicedata = self.address
                    
                    
                    print("Successfuly fetch relataed data \(data)")
                    
                    if statusCode == 200 && status == 1{
                        
                        var bounds = GMSCoordinateBounds()
                        
                        let path = GMSMutablePath()
                        for i in 0..<self.address.count {
                            let dic = self.address[i] as! NSDictionary
                            let latitude = dic["latitude"] as! Double
                            let longitude = dic["longitude"] as! Double
                            
                            path.add(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                            bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                            
                        }
                        
                        let polygon = GMSPolygon(path: path)
                        polygon.fillColor = UIColor(hexString: "#42c0c4" , alpha: 0.5)
                        polygon.strokeColor = .red
                        polygon.strokeWidth = 1.0
                        polygon.map = self.mapview
                        
                        self.mapview.animate(with:GMSCameraUpdate.fit(bounds,withPadding: 15.0))
                        self.mapview.isHidden = false
                        self.getSubCommnity()
                        
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
    
    private func getSubCommnity() {
        
        let neighbourHoodId = UserDefaultsManager.instance.getNeighbourHoodId()!
        
        let url = URL(string:"\(HelperFuntions.getSubCommunites)\(neighbourHoodId)")
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
                    
                    self.getAllbuttonsApi()
                    
                case .failure(let error):
                    print(error)
                    
                    HUD.hide()
                }
                
            }
            
        }
    }
    
    private func getAllbuttonsApi() {
        
        
        let neighbourHoodId = UserDefaultsManager.instance.getNeighbourHoodId()!
        let url = URL(string:"\(HelperFuntions.getAllbuttons)\(neighbourHoodId)")
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
                    
                    
                    
                    
                    if let res = responseJSON.result.value as? NSDictionary
                    {
                        
                        let dict = res
                        //var status = ""
                        // var eMsg = ""
                        
                        
                        let json = JSON(dict.object(forKey: "subButtonsLookup") as Any).array
                        for a in json!
                        {
                            self.obj = SubCommunitiesButton(json:a)
                            self.subCommuntiesButton.append(self.obj!)
                            
                        }
                        
                        //focus current sub commit
                        let subcommunityId = UserDefaultsManager.instance.getSubCommunityId()
                        for x in self.subCommuntiesButton {
                            
                            if (x.subCommunitiesID == subcommunityId) {
                                self.ShowNext(button: x)
                                break
                            }
                        }
                        
                        print("Here :\(self.subCommuntiesButton)")
                        
                    }
                    
                    let recievedCode = data as! NSDictionary
                    
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let result = req.value(forKey: "result") as! Bool
                    let status = req.value(forKey: "status") as! Int
                    
                    
                    print("Successfuly fetch relataed data \(data)")
                    
                    
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1 && result == true{
                            for i in 0..<self.subCommuntiesButton.count {
                                // addmarker
                                let dic = self.subCommuntiesButton[i]
                                let lat = dic.latitude
                                let long = dic.longitude
                                let marker = GMSMarker()
                                let latd = Double(lat!) ?? 0.0000
                                let longd = Double(long!) ?? 0.0000
                                
                                
                                // I have taken a pin image which is a custom image
                                let markerImage = UIImage(named: "addmarker")!.withRenderingMode(.alwaysTemplate)
                                
                                //creating a marker view
                                let markerView = UIImageView(image: markerImage)
                                
                                //changing the tint color of the image
                                markerView.tintColor = UIColor.red
                                
                                marker.position = CLLocationCoordinate2D(latitude: latd, longitude: longd)
                                
                                marker.icon = markerImage
                                //marker.title = "New Delhi"
                                //marker.snippet = "India"
                                marker.map = self.mapview
                                
                            }
                            if self.subCommuntiesButton.count >  1 {
                                    let dic = self.subCommuntiesButton[0]
                                    let lat = dic.latitude
                                    let long = dic.longitude
                                
                                UserDefaults.standard.set(lat,forKey: "MapUserDefaultLatPosition")
                                UserDefaults.standard.set(long,forKey: "MapUserDefaultLngPosition")
                            }
                            

                            
                            
                            
                        }else if status == 200 && status == 2 && result == false {
                            // self.DisplayMessage(userMessage: message, title: "user info")
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
    
    private func getBoundries() {
        
        //HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.getBoundries)")
        let postString = ["neighbourhoodId": 1] as [String : Any]
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
                    print("boundries data \(data)")
                    
                    
                    
                    let recievedCode = data as! NSDictionary
                    
                    self.boundries = recievedCode.value(forKey: "boundaries") as! NSDictionary
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let status = req.value(forKey: "status") as! Int
                    
                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1{
                            
                            print("boundries \(self.boundries.count)")
                            
                            let southLatitude = self.boundries["southLatitude"] as! Double
                            let southLongitude = self.boundries["southLongitude"] as! Double
                            let eastLatitude = self.boundries["eastLatitude"] as! Double
                            let eastLongitude = self.boundries["eastLatitude"] as! Double
                            //                            let westLatitude = self.boundries["westLatitude"] as! Double
                            //                            let westLongitude = self.boundries["westLongitude"] as! Double
                            let northLatitude = self.boundries["northLatitude"] as! Double
                            let northLongitude = self.boundries["northLongitude"] as! Double
                            
                            
                            
                            var region:GMSVisibleRegion = GMSVisibleRegion()
                            region.nearLeft = CLLocationCoordinate2DMake(southLatitude, southLongitude)
                            region.farRight = CLLocationCoordinate2DMake(northLatitude,northLongitude)
                            
                            //let bounds = GMSCoordinateBounds(coordinate: region.nearLeft,coordinate: region.farRight)
                            //let camera = self.mapview.camera(for: bounds, insets:UIEdgeInsets.zero)
                           // self.mapview.camera = camera!;
                            
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
    
    @IBAction func ZoomIn(_ sender: Any) {
        zoom = zoom + 1
        self.mapview.animate(toZoom: zoom)
        print("zoom\(zoom)")
    }
    @IBAction func ZoomOut(_ sender: Any) {
        
        zoom = zoom - 1
        self.mapview.animate(toZoom: zoom)
        
        print("zoom\(zoom)")
    }

    @IBAction func viewProfile(_ sender: Any) {
        if let vc = UIStoryboard(name: "Locations", bundle: nil).instantiateViewController(withIdentifier: "ShowUserInterestViewController") as? ShowUserInterestViewController
        {
            vc.subcommonID =  self.subcommonID
            self.showDialog.alpha = 0
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
    
}
