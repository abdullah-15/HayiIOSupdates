//
//  ImageUploadViewController.swift
//  hayi-ios2
//
//  Created by Mohsin on 23/09/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class ImageUploadViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var isnextbtn: RoundButton!
    var isCheck1 : Bool = true
    var ischeck3 : Bool = true
    
    var isOne : Int = 0
    var isTwo : Int = 1
    var isThree : Int = 2
    var isFour : Int =  3
    var logoImages: [UIImage] = []
    var valuesdata : [String] = []
    
    @IBOutlet weak var img3: UIImageView!
    
    @IBOutlet weak var mainView1: UIView!
    
    @IBOutlet weak var crossImage1: UIButton!
    @IBOutlet weak var crossImage2: UIButton!
    
    @IBOutlet weak var mainView3: UIView!
    
    @IBOutlet weak var img1: UIImageView!
    
    var isImageOneUploaded: Bool = false
    var isImageTwoUploaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
        //self.isnext.isEnabled = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ImageUploadViewController.tappedMe))
        img1.addGestureRecognizer(tap)
        img1.isUserInteractionEnabled = true
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(ImageUploadViewController.tappedMe2))
        img3.addGestureRecognizer(tap2)
        img3.isUserInteractionEnabled = true
        
        
        crossImage1.layer.cornerRadius = 0.5 * crossImage1.bounds.size.width
        crossImage1.clipsToBounds = true
        crossImage2.layer.cornerRadius = 0.5 * crossImage2.bounds.size.width
        crossImage2.clipsToBounds = true
        
        mainView1.bringSubviewToFront(crossImage1)
        mainView3.bringSubviewToFront(crossImage2)
        
        
        let yourBackImage = UIImage(named: "Back")
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.title = "Verify Documents"
    }
    
    @objc func tappedMe()
        
    {
        
        
        print("Tapped on Image")
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    @objc func tappedMe2()
        
    {
        print("Tapped on Image")
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func crossImage1OnePressed(_ sender: Any) {
        isCheck1 = true
        //img1.image = nil
        img1.image = UIImage(named: "backBg")
        img1.contentMode = .scaleAspectFit
        logoImages.removeFirst()
        
        if !ischeck3 {
            isCheck1 = false
            self.ischeck3 = true
            img1.image = img3.image
            img1.contentMode = .scaleAspectFill
            img3.image = UIImage(named: "backBg")
            img3.contentMode = .scaleAspectFit
            
        }
    }
    @IBAction func crossImage2Pressed(_ sender: Any) {
        self.ischeck3 = true
        //img1.image = nil
        img3.image = UIImage(named: "backBg")
        img3.contentMode = .scaleAspectFit
        
        
        logoImages.removeLast()
    }
    
    @IBAction func cross3(_ sender: Any) {
        //img3.image = nil
        ischeck3 = true
        //logoImages.remove(at: 2)
        img3.image = UIImage(named: "backBg")
        
        
    }
    
    func openGallary()
    {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:
        [UIImagePickerController.InfoKey : Any]) {
        
        
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // self.img1.contentMode = .scaleAspectFit
            //self.img1.image = pickedImage
            
            
            if (isCheck1) {
                
                isCheck1  = false
                imagePicker.allowsEditing = false
                // self.savebtn.isEnabled = true
                //imagePicker.sourceType = .photoLibrary
                
                
                
                // img1.isUserInteractionEnabled = true
                img1.contentMode = .scaleAspectFill
                img1.image = pickedImage
                logoImages.append(pickedImage)
                // self.isnext.isEnabled = true
                
                // uploadImage(image: pickedImage)
                
                
            }
            else if (ischeck3){
                
                ischeck3  = false
                
                imagePicker.allowsEditing = false
                // imagePicker.sourceType = .photoLibrary
                
                
                //img3.isUserInteractionEnabled = true
                img3.contentMode = .scaleAspectFill
                img3.image = pickedImage
                logoImages.append(pickedImage)
                
            }
            else {
                
                isCheck1  = false
                imagePicker.allowsEditing = false
                // self.savebtn.isEnabled = true
                //imagePicker.sourceType = .photoLibrary
                
                // img1.isUserInteractionEnabled = true
                img1.contentMode = .scaleAspectFill
                img1.image = pickedImage
                logoImages.append(pickedImage)
                // self.isnext.isEnabled = true
            }
           
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func custom(userMessage:String , title: String) -> Void {
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
    
    
    @IBAction func back(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func uploadImage (image: UIImage,number: Int) -> Void
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
                            let final = URL(string: message)
                            self.valuesdata.append(message)
                            
                            //Check if both uploaded or not
                            
                            if number == 1 {
                                self.isImageOneUploaded = true
                            }
                            if number == 2 {
                                self.isImageTwoUploaded = true
                            }
                            
                            if self.logoImages.count == 1{
                                
                                
                                let values = self.valuesdata.joined(separator: ",")
                                self.uploadDocuments(path: values)
                            }
                            else if self.isImageTwoUploaded == true  && self.isImageTwoUploaded{
                                
                                let values = self.valuesdata.joined(separator: ",")
                                self.uploadDocuments(path: values)
                            }
                            
                            print(message)
                            // Move to Thankyou Message
                            
                            
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
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self .present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alertWarning = UIAlertView(title:"Warning", message: "You don't have camera", delegate:nil, cancelButtonTitle:"OK", otherButtonTitles:"")
            alertWarning.show()
        }
    }
    
    private func uploadDocuments(path:String){
        
        let userId =  UserDefaults.standard.value(forKey: KeyUnApproved) as! Int
        
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.document)")
        let postString = ["userId" : userId,
                          "path" : path,
            ] as [String : Any]
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
                            self.DisplayMessage(userMessage: message, title: "Error While Uploading")
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
    
    
    @IBAction func uploadimages(_ sender: Any) {
        
        if logoImages.count >= 1 {
            
            var index = 1
            for i in logoImages {
                
                uploadImage(image: i,number: index)
                index = index + 1
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
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        // self.navigationController?.isNavigationBarHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.isNavigationBarHidden = true
        
    }
    
    func image(image1: UIImage, isEqualTo image2: UIImage) -> Bool {
        let data1: NSData = image1.pngData()! as NSData
        let data2: NSData = image2.pngData()! as NSData
        return data1.isEqual(data2)
    }
}
