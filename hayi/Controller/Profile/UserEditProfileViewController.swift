import UIKit
import Alamofire
import PKHUD
import SelectionList
import CropViewController
import SwiftyJSON


class UserEditProfileViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate , TOCropViewControllerDelegate {
    
    private var croppingStyle = TOCropViewCroppingStyle.circular
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    
    var imagePicker = UIImagePickerController()
    
    var selected  = [Int]()

    var selectedInterest = [Int]()
    
    var modelselectedSkills = [userSkills]()
    var modelselectedInterest = [userInterest]()
    var imageurl : String?
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var subCommunity: UILabel!
    @IBOutlet weak var neighbourHood: UILabel!
    
    @IBOutlet weak var profileHeaderContainer: NSLayoutConstraint!
    
    var stringArray = [String]()
    var stringArrays = [String]()
    var idarray1 = [Int]()
    var idarray = [Int]()
    @IBOutlet weak var select: SelectionList!
    
    @IBOutlet weak var newView: SelectionList!
    var myArray  = [Int]()
    var showInterest = [userInterest]()
    var showSkills = [userSkills]()
    
    @IBOutlet weak var collectionView1: UICollectionView!
    
    @IBOutlet weak var alertShow: UIView!
    @IBOutlet weak var job: UITextField!
    
    @IBOutlet weak var nationality: UITextField!
    @IBOutlet weak var profileImg: UIImageView!
    
    
    @IBOutlet weak var resident: UITextField!
    var interest :  NSArray = NSArray()
    var skills : NSArray =  NSArray()
    
    var itemList = [saveUser]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        // Do any additional setup after loading the view.
        collectionView1.delegate = self
        collectionView1.dataSource = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UserEditProfileViewController.tappedMe))
        
        profileImg.addGestureRecognizer(tap)
        profileImg.isUserInteractionEnabled = true
        let searchButton = UIBarButtonItem(title : "Logout",  style: .plain, target: self,  action: #selector(didTapEditButton))
        navigationItem.rightBarButtonItems = [searchButton]
        self.title = "Edit profile"
        
        loadProfileFromDefaults()
        
    }
    

    
    @objc func didTapEditButton(sender: AnyObject){
        
        self.ConfirmLogout()    
    }
    
    func ConfirmLogout() -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Log out", message: "Do you really want to log out", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default){(
                ACTION:UIAlertAction!) in
                //self.emptyAllTextFields()
                
            }
            alertController.addAction(cancelAction)
            
            let okAction = UIAlertAction(title: "OK", style: .default){(
                ACTION:UIAlertAction!) in
                //self.emptyAllTextFields()
                
                let userId = UserDefaultsManager.instance.CurrentUserId()!
                
                self.UpdateFCMToken(userId:userId ,token:"")
                
                UserDefaultsManager.instance.logOut()
                
                UserDefaultsManager.instance.setValueFor(value: nil, key: KIsRegisteredFirebase)
                
                FUser.logOutCurrentUser { (val) in
                    print("Firebase logout")
                }
                
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "MainScreenVC") as? MainScreenVC
                {
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func UpdateFCMToken(userId: Int, token: String){
        
        let url = HelperFuntions.UpdateUserFCMToken
        
            let postString = ["userId": userId, "fcmToken": token] as [String : Any]
            
            let MyHeader = ["content-type": "application/json"]
            
            Alamofire.request(url, method: .post, parameters: postString, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
                DispatchQueue.main.async {
                    
                    print("Save FCM Token")
                    
                    switch responseJSON.result{
                        
                    case .success(let data):
                        var statusCode:Int = 0
                        if responseJSON.result.value != nil{
                            
                            statusCode = (responseJSON.response?.statusCode)!
                            print("...HTTP code: \(statusCode)")
                        }
                        print("all reponse data \(data)")
                        
                    case .failure(let error):
                        print(error)
                        //HUD.hide()
                    }
                }
        }
    }
    
    @objc func tappedMe()
        
    {
        
        if profileImg.image != nil {
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
        }else{
            
        }
        
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
        
        if !HelperFuntions.validateRequiredField(nationality.text!){
            
            HelperFuntions.showAlert("Erorr", withMessage: "Please enter Nationality")
            return false
        }
        
        if !HelperFuntions.validateRequiredField(resident.text!){
            
            HelperFuntions.showAlert("Error", withMessage: "Please enter Resident Since.")
            return false
        }
        
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:
        [UIImagePickerController.InfoKey : Any]) {
        
        
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //cropView
            let cropViewController = TOCropViewController(croppingStyle: croppingStyle,image: pickedImage)
            cropViewController.delegate = self
            cropViewController.aspectRatioPreset = .presetSquare;
            cropViewController.aspectRatioLockEnabled = true
            cropViewController.resetAspectRatioEnabled = false
            cropViewController.aspectRatioPickerButtonHidden = true
            
            
            if croppingStyle == .circular {
                if picker.sourceType == .camera {
                    picker.dismiss(animated: true, completion: {
                        self.present(cropViewController, animated: true, completion: nil)
                    })
                } else {
                    picker.pushViewController(cropViewController, animated: true)
                }
            }
            else {
                
                picker.dismiss(animated: true, completion: {
                    self.present(cropViewController, animated: true, completion: nil)
                    
                })
            }
            
            
            
        }
        
        
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int)
    {
        // 'image' is the newly cropped version of the original image
        
        // updateImageViewWithImage(image, fromCropViewController: cropViewController)
        self.profileImg.image = image
        
        self.dismiss(animated: true, completion: nil)
        uploadImage(image: image)
        
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToCircularImage image: UIImage, with cropRect: CGRect, angle: Int) {
        
        
        self.profileImg.image = image
        self.dismiss(animated: true, completion: nil)
        uploadImage(image: image)
    }
    
    
    @IBAction func updateBio(_ sender: Any) {
        if validateContactUsFields() {
            self.updateInfoBio()
        }
        
    }
    
    private func uploadDocuments(path:String){
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.document)")
        let postString = ["userId" : UserDefaults.standard
            .value(forKey: "userID")!,
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
                            print("Successfuly upload")
                            
                            
                            
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
    
    private func updateInterestByArray(interestID : String,selected : [userInterest]){
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.updateInterest)")
        let postString = ["userID" : UserDefaults.standard
            .value(forKey: "userID")!,
                          "interestIDs" : interestID,
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
                            // self.collectionView1.reloadData()
                            // self.custom(userMessage: message, title: "user info")
                            print("Successfuly upload")
                            
                            var obje : [NSDictionary] = []
                            
                            for x in self.modelselectedInterest {
                             
                                let name  = x.iName!
                                let id = x.sid!
                                let interestDict:NSDictionary = ["name": name,"interestId": id]
                                obje.append(interestDict)
                            
                            }
                            
                            let jsont:NSDictionary = ["interest": obje]
                            
                            let ints = jsont["interest"] as! NSArray
                            
                            //let nsarray : NSArray = ["intrest": interest]
                            
                            UserDefaultsManager.instance.UpdateUserInterest(interests: ints)
                            
                            
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = true
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = true
        self.hidesBottomBarWhenPushed = true
    }
    
    private func updateSkilsByArray(interestID : String){
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.updateSkilss)")
        let postString = ["userID" : UserDefaults.standard
            .value(forKey: "userID")!,
                          "skillsIDs" : interestID,
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
                            // self.collectionView2.reloadData()
                            
                            // self.custom(userMessage: message, title: "user info")
                            print("Successfuly upload")
                            
                            
                            
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
    
    private func updateInterest(interestID : Int){
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.updateInterest)")
        let postString = ["userID" : UserDefaults.standard
            .value(forKey: "userID")!,
                          "interestIDs" : interestID,
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
                    print("Successfuly delete Interest ==\(data)")
                    
                    
                    
                    let recievedCode = data as! NSDictionary
                    
                    
                    let status = recievedCode.value(forKey: "status") as! Int
                    let result = recievedCode.value(forKey: "result") as! Bool
                    let message =  recievedCode.value(forKey: "msg") as! String
                    
                    
                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1 && result == true{
                            //                             NotificationCenter.default.post(name: Notification.Name("loadprofile"), object: nil)
                            // self.custom(userMessage: message, title: "user info")
                            
                            print("Successfuly upload")
                            if self.modelselectedInterest.count == 0 {
                                self.AllDelete(interestID: 0)
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
    private func AllDelete(interestID : Int) {
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.updateInterest)")
        let postString = ["userID" : UserDefaults.standard
            .value(forKey: "userID")!,
                          "interestIDs" : interestID,
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
                    print("Successfuly delete Interest ==\(data)")
                    
                    
                    
                    let recievedCode = data as! NSDictionary
                    
                    
                    let status = recievedCode.value(forKey: "status") as! Int
                    let result = recievedCode.value(forKey: "result") as! Bool
                    let message =  recievedCode.value(forKey: "msg") as! String
                    
                    
                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1 && result == true{
                            //                             NotificationCenter.default.post(name: Notification.Name("loadprofile"), object: nil)
                            // self.custom(userMessage: message, title: "user info")
                            
                            print("Successfuly Deleted")
                            
                            
                            
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
    
    private func getAllInterest() {
        self.stringArray.removeAll()
        
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.getAllInterest)")
        
        let MyHeader = ["content-type": "application/json"]
        // print(postString)
        
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
                    print("All interest data \(data)")
                    
                    
                    
                    let recievedCode = data as! NSDictionary
                    
                    
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let status = req.value(forKey: "status") as! Int
                    let result =  req.value(forKey: "result") as! Bool
                    let datashow = recievedCode.value(forKey: "interests") as! NSArray
                    
                    
                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1 && result == true{
                            for i in 0..<datashow.count {
                                let dic = datashow[i] as! NSDictionary
                                let name =  dic["name"] as? String
                                let id =  dic["interestsID"] as? Int
                                
                                let obj = userInterest(iName: name, sid: id)
                                self.stringArray.append(name!)
                                self.idarray.append(id!)
                                self.showInterest.append(obj)
                                print(self.showInterest.count)
                                
                                // self.collection1.reloadData()
                                
                            }
                            
                            self.alertShow.alpha = 1
                            self.newView.items = self.stringArray
                            self.newView.allowsMultipleSelection = true
                            //self.newView.selectedIndexes = [0, 1]
                            self.newView.addTarget(self, action: #selector(self.selectionChanged), for: .valueChanged)
                            self.newView.setupCell = { (cell: UITableViewCell, _: Int) in
                                cell.textLabel?.textColor = .gray
                                
                            }
                            // self.custom(userMessage: message, title: "user info")
                            print("Successfuly upload")
                            
                            
                            
                        }else if status == 200 && status == 2 && result == false {
                            //self.DisplayMessage(userMessage: message, title: "user info")
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
    
    
    func uploadImage (image: UIImage) -> Void
    {
        
        
        let url = URL(string:"\(HelperFuntions.imagePost)")
        
        let imageData = image.jpegData(compressionQuality: 0.2)
        
        Alamofire.upload(multipartFormData: { (data) in
            
            let timeStamp = (NSDate().timeIntervalSince1970 * 100000)
            
            data.append(imageData!, withName: "file",fileName: "pic\(timeStamp).png" , mimeType: "image/png")
            
        }, to: url!, method: .post , headers:nil,
           encodingCompletion: { (encodeResult) in
            switch encodeResult {
            case .success(let upload, _, _):
                
                upload.responseJSON(completionHandler: { (response) in
                    
                    switch response.result
                    {
                    case .success(let responseJSON):
                        guard let dicResponse = responseJSON as? NSDictionary else{
                            return
                        }
                        
                        print("Response : \((dicResponse))")
                        let status = dicResponse["status"] as! Int
                        let result = dicResponse["result"] as! Bool
                        
                        
                        if status == 1 && result == true{
                            
                            let url = dicResponse["msg"] as! String
                            self.updateProfileImage(url: url)
                            
                        }
                        
                    case .failure(let error):
                        
                        print(error)
                        
                        break
                    }
                })
            case .failure(let error):
                print(error)
                
                break
            }
            
        })
        
    }
    
    private func updateProfileImage(url: String) {
        
        
        let defaults = UserDefaultsManager.instance
        
        let userId = defaults.CurrentUserId()
        
        var  postring = [String : Any]()
        
        postring = ["userId": userId, "url" : url]
        
        let MyHeader = ["content-type": "application/json"]
        
        let apiUrl = URL(string:"\(HelperFuntions.updateProfileImage)")
    
        Alamofire.request(apiUrl!, method: .post, parameters: postring, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
            
            switch responseJSON.result{
                
            case .success(let data):
                
                var statusCode:Int = 0
                if responseJSON.result.value != nil{
                    
                    statusCode = (responseJSON.response?.statusCode)!
                    print("...HTTP code: \(statusCode)")
                }
                
                print("Neighbourhood data \(data)")
                
                let recievedCode = data as! NSDictionary
                
                let dict:NSDictionary = [kAVATAR:url]
                
                updateCurrentUserInFirestore(withValues: dict as! [String : Any], completion: {(error)in
                
                    if let err = error {
                        
                        print(err.localizedDescription)
                    }
                    
                })

                print("Successfuly fetch relataed data \(data)")
            case .failure(let error):
                print(error)
                HUD.hide()
            }
            
            UserDefaultsManager.instance.setValueFor(value: url, key: KeyProfileImage)
            let fuserId =  FUser.currentId()
            updateAvatars(userId: fuserId, avatar: url)
            
        }
    }
    
    private func updateInfoBio() {
        
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.updateBio)")
        var  postring = [String : Any]()
        
        let defaults = UserDefaultsManager.instance
        
        let userId =  defaults.CurrentUserId()
        
        let nationational = nationality.text!
        let jobTitle = job.text!
        let residentSince =  resident.text!
        
        
        postring = ["userID": userId, "nationality" : nationational, "jobTitle" : jobTitle, "residentSince" : residentSince]
        
        let MyHeader = ["content-type": "application/json"]
        
        
        
        Alamofire.request(url!, method: .post, parameters: postring, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
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
                    let result = recievedCode.value(forKey: "status") as! Bool
                    let status = recievedCode.value(forKey: "result") as! Int
                    
                    print("Successfuly fetch relataed data \(data)")
                    
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1 && result == true{
                            
                            
                            HelperFuntions.showAlert("Success", withMessage: "Bio Updated")
                            
                            let defaults = UserDefaultsManager.instance
                            
                            defaults.setValueFor(value: nationational, key: KeyNationality)
                            
                            defaults.setValueFor(value: jobTitle, key: KeyJobTitle)
                            
                            defaults.setValueFor(value: residentSince, key: KeyResidentSince)
                            
                        }else if statusCode == 200 && status == 2 && result == false {
                            //self.customDisplay(userMessage: message, title: "Info")
                            
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
    
    
    @IBAction func logOut(_ sender: Any) {
        
    }
    
    @IBAction func addInterest(_ sender: Any) {
        
        
        self.getAllInterest()
        
        
    }
    
    
    @objc func selectionChanged() {
        DispatchQueue.main.async {
            //  print(self.newView.selectedIndexes)
            self.selectedInterest = self.newView.selectedIndexes
            
        }
        
    }
    
    @IBAction func uploadinterest(_ sender: Any) {
        
        var selected = [userInterest]()
        
        for i in self.selectedInterest
        {
            if self.showInterest.indices.contains(i)
            {
                let sel = self.showInterest[i]
                if !(self.modelselectedInterest.contains(where: { ($0.iName ?? "") == (sel.iName ?? "") }))
                    
                {
                    selected.append(self.showInterest[i])
                }
                
            }
        }
        
        
        
        for i in selected
        {
            if self.modelselectedInterest.contains(where: { ($0.iName ?? "") == (i.iName ?? "") })
            {
                if let index = selected.firstIndex(of: i)
                {
                    selected.remove(at: index)
                }
            }
        }
        
        for i in selected
        {
            modelselectedInterest.append(i)
        }
        collectionView1.reloadData()
        
        
        var userid : Int?
        var string : String = ""
        selected =  modelselectedInterest
        
        for i in 0..<selected.count {
            if(i == (selected.count-1)) {
                userid = selected[i].sid
                string += "\(userid!)"
            }else{
                userid = selected[i].sid
                string += "\(userid!),"
            }
            
            
            
        }
        print(string)
        alertShow.alpha = 0
        
        if string != "" {
            self.updateInterestByArray(interestID: string,selected : selected )
        }
        
        print("your ids \(string)")
        
    }
    
    @IBAction func cross(_ sender: Any) {
        alertShow.alpha = 0
    }
    
}

// MARK: Edit Profile
extension UserEditProfileViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView1 {
            return  self.modelselectedInterest.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            let cellA = self.collectionView1.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! userInterestEditProfile
            cellA.userInterest.text =  modelselectedInterest[indexPath.row].iName
            cellA.interesetEdit.tag = indexPath.row
            cellA.interesetEdit.addTarget(self, action: #selector(UserEditProfileViewController.displaycellDetails(_:)), for:.touchUpInside)
            // Set up cell
        cellA.userInterest.frame.size.width = cellA.userInterest.text?.width(constraintedheight: 40, fontSize: 15, text: cellA.userInterest.text ?? "") ?? 60
        cellA.labelContainer.frame.size.width = cellA.userInterest.text?.width(constraintedheight: 40, fontSize: 15,text: cellA.userInterest.text ?? "") ?? 60
        
        cellA.labelContainer.layer.cornerRadius = 10
        
            return cellA
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let text = modelselectedInterest[indexPath.row].iName
        
        //let fontAttributes = NSAttributedString.Key.font: UIFont(name: UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
        
        let width = text?.width(constraintedheight: 40, fontSize: 15,text: text ?? "") ?? 60
        
        return CGSize(width: width + 15 , height: 40)
    }
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 10
    }
    
    @objc func displaycellDetails(_ sender : UIButton) {
        print(sender.tag)
        
        if modelselectedInterest.indices.contains(sender.tag)
        {
            modelselectedInterest.remove(at:sender.tag)
        }
        var userid : Int?
        var string : String = ""
        //selected =  modelselectedSkills
        for i in 0..<modelselectedInterest.count{
            if(i == (modelselectedInterest.count-1)) {
                userid = modelselectedInterest[i].sid
                string += "\(userid!)"
            }else{
                userid = modelselectedInterest[i].sid
                
                string += "\(userid!),"
            }
            
        }
        
        self.updateInterestByArray(interestID: string,selected: modelselectedInterest)
        
        self.collectionView1.reloadData()
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
        
    }
}


//MARK: Load User Profile
extension UserEditProfileViewController {
    
    func loadProfileFromDefaults() {
        
        
        let defaults = UserDefaultsManager.instance
        
        self.name.text = defaults.getFullName()
        
        self.subCommunity.text = defaults.getValueFor(key: KeySubCommunity) ?? " "
        self.neighbourHood.text = defaults.getValueFor(key: KeyNeighbourHood) ?? " "
        
        
        let subname = self.subCommunity.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let neihName = self.neighbourHood.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if subname == neihName {
            self.neighbourHood.isHidden = true
            self.neighbourHood.frame.size.height = 0
            self.profileHeaderContainer.constant = 210
        }
        else {
            self.neighbourHood.isHidden = false
            self.neighbourHood.frame.size.height = 20
            self.profileHeaderContainer.constant = 230
        }
        
        self.nationality.text = defaults.getValueFor(key: KeyNationality) ?? ""
        
        self.job.text = defaults.getValueFor(key: KeyJobTitle) ?? ""
        
        self.resident.text = defaults.getValueFor(key: KeyResidentSince) ?? ""
        
        
        var profileImage:String? = defaults.getValueFor(key: KeyProfileImage)
        
        if profileImage != nil {
            
            profileImage = profileImage!.replacingOccurrences(of: " ", with: "%20")
            profileImage = "\(profileImage!)"
            
            self.profileImg.layer.cornerRadius = self.profileImg.frame.height/2
            self.profileImg.clipsToBounds = true
            self.profileImg.sd_setImage(with: URL(string:profileImage!))
        }
        else {
            
            let firstname = defaults.getValueFor(key: KeyFirstName)
            let lastname = defaults.getValueFor(key: KeyLastName)
            
            imageFromInitials(firstName: firstname, lastName: lastname) { (image) in
                DispatchQueue.main.async {
                    self.profileImg.image = image
                }
            }
        }
        
        
        self.interest = defaults.getInterests()
        
        for i in 0..<self.interest.count {
            let dic = self.interest[i] as! NSDictionary
            
            let name =  dic["name"] as? String
            let id =  dic["interestId"] as? Int
            
            let obj = userInterest(iName: name, sid: id)
            
            self.modelselectedInterest.append(obj)
            
        }
        self.collectionView1.reloadData()
        
    }
    
    
}
