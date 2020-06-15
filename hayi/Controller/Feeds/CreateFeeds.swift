//
//  CreateFeeds.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 21/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import Photos
import iOSDropDown
import Alamofire
import PKHUD
import SwiftyJSON
import OpalImagePicker
import AVFoundation
import AVKit

struct category {
    var id : Int?
    var name : String?
}

class CreateFeeds: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate,UITextViewDelegate {
    
    //MARK: Instance View Properties
    
    var videoURL : URL?
    var valuesdata : [String] = []
    var message: String?
    var postTypeID : Int?
    var isCheckImage : Bool?
    var isCheckVideo : Bool?
    var isCheckText : Bool?
    var imagesPath : String?
    var videoPath : String?
    var path : String?
    var yourArray = [category]()
    var stringArray = [String]()
    var idarray = [Int]()
    var frameHeight:CGFloat?
    
    var categoryID : Int = AppManager.categoryID//1
    var categoryList : NSArray =  NSArray()
    var selectedImages = [PHAsset]()
    var selectedImage = [UIImage]()
    
    @IBOutlet weak var ctHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var addVideoIcon: UIImageView!
    @IBOutlet weak var addphotoIcon: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var addphoto: UIButton!
    @IBOutlet weak var saySomething: UITextView!
    @IBOutlet weak var addvideo: UIButton!
    @IBOutlet weak var showThumb: UIImageView!
    @IBOutlet weak var selectCat: DropDown!
    @IBOutlet weak var playbtn: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var collectShow: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllCategories()
        
        self.showThumb.bringSubviewToFront(self.playbtn)
      collectShow.delegate = self
      collectShow.dataSource = self
       
        self.saySomething.delegate = self
        self.saySomething.placeholder = "Say Something"
        self.name.text = UserDefaultsManager.instance.getFullName()
        let profileImg = UserDefaultsManager.instance.getValueFor(key: KeyProfileImage)
        
        if let profileImg = profileImg  {
        
            self.profileImage.sd_setImage(with: URL(string:profileImg))
        }
        else {
            
            self.profileImage.image = UIImage(named: "user (1)")
        }

        self.title = "Create Post"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
     
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(createPost(_:)))
        
        let yourBackImage = UIImage(named: "Back")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.collectionViewTapped(_:)))
        
        //saySomething.becomeFirstResponder()
        
        self.collectShow.addGestureRecognizer(tap)
        
        selectCat.didSelect{(selectedText , index ,id) in
            print( "Selected String: \(selectedText) \n index: \(self.idarray[index]) id :\(id)")
            self.categoryID = id
            
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.ctHeightConstraints.constant = self.view.frame.size.height > 832 ? self.view.frame.size.height: 832
        self.frameHeight =  self.ctHeightConstraints.constant
        //self.view.frame.size.height
        self.view.bringSubviewToFront(self.saySomething)
        self.saySomething.delegate = self
        
    }
    
    @objc func collectionViewTapped(_ sender: UITapGestureRecognizer? = nil) {
     
        print("Video View Tapped")
        
        saySomething.becomeFirstResponder()
    }
    
    @IBAction func deleteVideo(_ sender: Any) {
        self.videoURL = nil
        self.showThumb.image = nil
        self.videoView.alpha = 0
        self.addphoto.alpha = 1
        self.collectShow.alpha = 1
        self.addphotoIcon.alpha = 1
        
    }
    
    @IBAction func playVideo(_ sender: Any) {
        let player = AVPlayer(url: (videoURL)!)
        let vcPlayer = AVPlayerViewController()
        vcPlayer.player = player
        self.present(vcPlayer, animated: true, completion: nil)
        
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
    do {
    let asset = AVURLAsset(url: path, options: nil)
    let imgGenerator = AVAssetImageGenerator(asset: asset)
    imgGenerator.appliesPreferredTrackTransform = true
    let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
    let thumbnail = UIImage(cgImage: cgImage)
    return thumbnail
    } catch let error {
    print("*** Error generating thumbnail: \(error.localizedDescription)")
    return nil
    }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:
        [UIImagePickerController.InfoKey : Any]) {
        self.videoView.alpha = 1
        
        self.videoURL = info[UIImagePickerController.InfoKey.mediaURL]  as! URL?
        print(self.videoURL!)
        self.dismiss(animated: true, completion: nil)
        self.showThumb.image = self.generateThumbnail(path: videoURL! as URL)
//        self.addphoto.alpha = 0
//        self.addphotoIcon.alpha = 0
        self.collectShow.alpha = 0

        let file = filesize(myurl:  self.videoURL!)
        if file > 2500 {
            self.DisplayMessage(userMessage: "please select video less then 25 MB", title: "info")
        }
        
       
     }
    
    func uploadImage (image: UIImage, number : Int) -> Void
    {
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        
        
        let url = URL(string:"\(HelperFuntions.imagePost)")
        
        
        let imageData = image.jpegData(compressionQuality: 0.2)
        
        
        Alamofire.upload(multipartFormData: { (data) in
            
            
        
            let timeStamp = NSNumber(value: Date().timeIntervalSince1970)

            data.append(imageData!, withName: "file",fileName: "pictiure\(timeStamp).png", mimeType: "image/png")
            
            
            
        }, to: url!, method: .post , headers:nil,
           encodingCompletion: { (encodeResult) in
            switch encodeResult {
            case .success(let upload, _, _):
                
                upload.responseJSON(completionHandler: { (response) in
                    // DispatchQueue.main.async {
                    HUD.hide()
                    //}
                    
                    switch response.result
                    {
                    case .success(let responseJSON):
                        guard let dicResponse = responseJSON as? NSDictionary else{
                            return
                        }
                        
                        print("Response : \((dicResponse))")
                        let isOKResult = dicResponse["status"] as! Int
                        let result = dicResponse["result"] as! Bool
                        if isOKResult == 1 && result == true{
                            let message  = dicResponse["msg"] as! String
                          //  let final = URL(string: message)
                            self.valuesdata.append(message)
                            print(message)
                            print("number == \(number) and image count \(self.selectedImage.count-1)")
                            
                            if self.selectedImage.count == 1{
                                 self.path = self.valuesdata[0]
                                print(" post ID  == \(self.postTypeID!) path == \(self.path)")
                                self.createpost(postTypeId: self.postTypeID!, postMessage: self.saySomething.text, contentPaths: self.path!)
                            }else{
                                
                            
                            if number == self.selectedImage.count-1{
                                for i in 0..<self.valuesdata.count {
                                    if i == self.valuesdata.endIndex-1{
                                        
                                    }else{
                                        self.path = self.valuesdata.joined(separator: ",")
                                    }
                                }
                                self.createpost(postTypeId: self.postTypeID!, postMessage: self.saySomething.text, contentPaths: self.path!)
                                
                            }
                            }
                            
                        }
                        
                    case .failure(let error):
                        
                        print(error)
                        
                        break
                    }
                })
            case .failure(let error):
                print(error)
                
                
                HUD.hide()
                
                
                break
            }
            
        })
        
    }
    
    func uploadVideo(videoUrl : URL)
    {
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        
        
        let url = URL(string:"\(HelperFuntions.imagePost)")
        
        
        
        Alamofire.upload(multipartFormData: { (data) in
            
             let timeStamp = NSNumber(value: Date().timeIntervalSince1970)
            
            
            data.append(videoUrl, withName: "file",fileName: "\(timeStamp).MP4", mimeType: "")
            
            
            
        }, to: url!, method: .post , headers:nil,
           encodingCompletion: { (encodeResult) in
            switch encodeResult {
            case .success(let upload, _, _):
                
                upload.responseJSON(completionHandler: { (response) in
                    // DispatchQueue.main.async {
                    HUD.hide()
                    //}
                    
                    switch response.result
                    {
                    case .success(let responseJSON):
                        guard let dicResponse = responseJSON as? NSDictionary else{
                            return
                        }
                        
                        print("Response : \((dicResponse))")
                        let isOKResult = dicResponse["status"] as! Int
                        let result = dicResponse["result"] as! Bool
                        if isOKResult == 1 && result == true{
                            let messageURL  = dicResponse["msg"] as! String
                          //  let final = URL(string: messageURL)
                            self.message = messageURL
                           // self.valuesdata.append(message)
                            print("video url :\(self.message!)")
                           // completion(self.message!)
                            
                            self.createpost(postTypeId: self.postTypeID!, postMessage: self.saySomething.text!, contentPaths: messageURL)
                            

                            
                        }
                        
                    case .failure(let error):
                        
                        print(error)
                        
                        break
                    }
                })
            case .failure(let error):
                print(error)
                
                
                HUD.hide()
                
                
                break
            }
            
        })
        
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        if Connectivity.isConnectedToInternet(){
        
        if self.selectedImage.count > 0{
            self.postTypeID = 2
     
            self.isCheckImage = true
            for i in 0..<self.selectedImage.count {
                let image = self.selectedImage[i]
                self.uploadImage(image: image, number: i )
                print(self.valuesdata.count)
                

            }
          
            
        }else if self.videoURL != nil {
            let file = filesize(myurl: self.videoURL!)
            if file > 2500 {
                self.DisplayMessa(userMessage: "Please select video less than 25 MB", title: "info")
            }else{
                self.postTypeID = 3
                self.isCheckVideo = true
                self.uploadVideo(videoUrl: self.videoURL!)
            }
           

            
        }else if !((self.saySomething.text?.isEmpty)!){
            self.postTypeID = 1
            self.isCheckText = true
            self.createpost(postTypeId: postTypeID!, postMessage: self.saySomething.text!, contentPaths: "")
            
        }else{
            self.DisplayMessa(userMessage: "Please say something", title: "info")
        }
        

        }else{
            self.DisplayMessage(userMessage: internetNot, title: "Info")
        }
        
    }
    
    func filesize(myurl : URL) -> Double{
        
        let data = NSData(contentsOf: myurl)!
        let fileSize = Double(data.length / 1024) //Convert in to MB
        print("File size in MB: ", fileSize)
         return fileSize
    }

    private func getAllCategories(){
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        
        let url = URL(string:"\(HelperFuntions.getAllcategories)")
        // print("url is \(url)" )
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
                    
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let result = req.value(forKey: "result") as! Bool
                    let status = req.value(forKey: "status") as! Int
                    
                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1 && result == true{
                            self.categoryList = (recievedCode.value(forKey: "postCategoryLookups") as? NSArray)!
                            for i in 0..<self.categoryList.count {
                                let dic = self.categoryList[i] as! NSDictionary
                                let name =  dic["name"] as? String
                                let id =  dic["postCategoriesId"] as? Int
                                
                                let obj = category(id: id, name: name)
                                self.stringArray.append(name!)
                                self.idarray.append(id!)
                                self.yourArray.append(obj)
                                print(self.yourArray.count)
                                
                                
                            }
                            self.selectCat.selectedIndex = AppManager.categoryID
                            self.selectCat.optionArray = self.stringArray
                            self.selectCat.optionIds = self.idarray
                            self.selectCat.rowBackgroundColor = .white
                            self.selectCat.selectedRowColor = .white
                            self.selectCat.checkMarkEnabled = false
                            self.selectCat.isSearchEnable = false
                            
                            var indx = AppManager.categoryID
                            
                            if indx == 1 {
                                indx = 0
                            }
                            else
                            {
                                if indx > 1 {
                                    indx -= 1
                                }
                            }
                            self.selectCat.text = AppManager.CategoryName
                            
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
   
    private func createpost(postTypeId : Int , postMessage : String , contentPaths : String){
       // let neighbourHoodId  = UserDefaults.standard
         //   .value(forKey: "neigbourhood")! as? Int
       
       
      //  print("neighbourhood value \(String(describing: neighbourHoodId))")
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        
        let url = URL(string:"\(HelperFuntions.creatpost)")
        // print("url is \(url)" )
        let postString = ["userId" : UserDefaults.standard
            .value(forKey: "userID")!,
                          "postTypeId" :postTypeId ,
                          "neighbourhoodsId" : UserDefaultsManager.instance.getNeighbourHoodId() ,
            "postMessage" : postMessage ,
            "postCategoriesId" : categoryID,
            "contentPaths" : contentPaths
            ] as [String : Any]
        
        print("postString :: \(postString)")

        let MyHeader = ["content-type": "application/json"]
        
        Alamofire.request(url!, method: .post, parameters: postString, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
            DispatchQueue.main.async {
                
                AppManager.shouldLoadPostsAgain = true
                
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
                    
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let result = req.value(forKey: "result") as! Bool
                    let status = req.value(forKey: "status") as! Int
                    
                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1 && result == true{
                            self.selectedImage.removeAll()
                            NotificationCenter.default.post(name: Notification.Name("loadBreakfast"), object: nil)
                            AppManager.shouldLoadPostsAgain = true
                            self.navigationController?.popViewController(animated: true)
                           
                         // self.DisplayMessage(userMessage: "Successfully posted", title: "Post")
                        }else if status == 200 && status == 2 && result == false {
                             self.DisplayMessage(userMessage: "Error", title: "user info")
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
    
    func DisplayMessa(userMessage:String , title: String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: userMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default){(
                ACTION:UIAlertAction!) in
                
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func AddPhotos(_ sender: Any) {
        
        if self.selectedImage.count == 9{
            self.DisplayMessa(userMessage: "Exceed the limit", title: "info")
        }else{
            let imagePicker = OpalImagePickerController()
            imagePicker.imagePickerDelegate = self
            imagePicker.maximumSelectionsAllowed = 10
            present(imagePicker, animated: true, completion: nil)
        }
        
        
       
       

    }
    
    @IBAction func AddVideos(_ sender: Any) {
    
        let imagePickerController = UIImagePickerController ()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        present(imagePickerController, animated: true, completion: nil)

    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 257, height: 204), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    @objc func deleteData(_ sender : UIButton) {
        print(sender.tag)
        let indexPath = IndexPath(item: sender.tag, section: 0)
      
        self.selectedImage.remove(at: indexPath.item)
        // self.collectionView1.reloadData()
        
        self.collectShow.performBatchUpdates({
            self.collectShow.deleteItems(at: [indexPath])
        }) { (finished) in
            self.collectShow.reloadItems(at: self.collectShow.indexPathsForVisibleItems)
        }
   
}
}
//MARK: CollectionView Delegate
extension CreateFeeds : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.self.selectedImage.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellA = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FeedCollectionViewCell
        
        let myImg = self.self.selectedImage[indexPath.row]
        
        //let image = self.getAssetThumbnail(asset: myImg)
              
        cellA.imageView.image = myImg
        
        cellA.cross.tag = indexPath.row
        cellA.cross.addTarget(self, action: #selector(CreateFeeds.deleteData(_:)), for:.touchUpInside)
        return cellA
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width , height: collectionView.frame.size.height )
    }
}
extension CreateFeeds : OpalImagePickerControllerDelegate {
    
    func imagePickerDidCancel(_ picker: OpalImagePickerController) {
        //Cancel action?
    }
    
    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingImages images: [UIImage]) {
        //Save Images, update UI
        
        picker.maximumSelectionsAllowed = picker.maximumSelectionsAllowed - images.count
        if picker.maximumSelectionsAllowed == 0{
            self.DisplayMessa(userMessage: "Exceed the Limit", title: "info")
        }else{
            self.selectedImage = self.selectedImage + images
            collectShow.reloadData()
        }
       
        //Dismiss Controller
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerNumberOfExternalItems(_ picker: OpalImagePickerController) -> Int {
        return 1
    }
       
    func imagePicker(_ picker: OpalImagePickerController, imageURLforExternalItemAtIndex index: Int) -> URL? {
        return URL(string: "https://placeimg.com/500/500/nature")
    }

}
extension CreateFeeds {
    //MARK: Text View Dynamic Height
    func textViewDidChange(_ textView: UITextView)
    {
        if textView.text.count > 0 {
            
            self.saySomething.placeholder = ""
        }
        else {
            self.saySomething.placeholder = "Say Something"
        }
        var frame = self.saySomething.frame
        frame.size.height = self.saySomething.contentSize.height
        //self.saySomething.frame = frame

          let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: frame.size.height))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: frame.size.height))
          var newFrame = textView.frame
          newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
          textView.frame = newFrame
        self.setContentViewHeight()
    }
    func setContentViewHeight() {
        
        self.ctHeightConstraints.constant = saySomething.frame.size.height + self.frameHeight!
    }
}
