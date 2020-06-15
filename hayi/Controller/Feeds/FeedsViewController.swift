

import UIKit
import Alamofire
import PKHUD
import SwiftyJSON
import SDWebImage
import AVKit
import AVFoundation
import Kingfisher
import MessageUI
import GSImageViewerController
import Firebase
import iOSDropDown


class FeedsViewController: UIViewController,FeedsViewCellDelegate,PostActionsDelegate,FeedsViewImageDelegate,ProfileViewDelegate,UITabBarControllerDelegate {
    
    deinit {
            NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: Properties
    
    var request: DataRequest?
    
    var Page: Int = 1
    var PageLimit: Int = 10
    var HasNext: Bool = true
    var CategoryLoaded:Int = 0
    
    var PostsLoaded = [post]()
    
    var  button = UIButton(type: .system)
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var currentUserAvatar: UIImageView!
    
    var dictArray = Array<Dictionary<String,Any>>()
    
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificatonArrived(_:)), name: NSNotification.Name(rawValue: "newnotification"), object: nil)
        
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.tableView.separatorColor = UIColor.clear
        setupTitleBar()
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        self.loadPosts()
        
        let profileImg = UserDefaultsManager.instance.getValueFor(key: KeyProfileImage)
        
        if profileImg != nil {
            
            self.currentUserAvatar.sd_setImage(with: URL(string:profileImg!))
        }
        else {
            
            self.currentUserAvatar.image = UIImage(named: "user (1)")
        }
        
        
        self.tableView.refreshControl =  refreshControl
        //refreshControl.attributedTitle = NSAttributedString(string: "Load earlier messages")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.updateServerUserIdFirebase()
        //Tab Bar Setting
        
        self.tabBarController?.delegate = self
        
        self.setUserPresenceStatus()
        
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let tabBarIndex = tabBarController.selectedIndex
        
        print(tabBarIndex)
        
        if tabBarIndex == 0 {
            DispatchQueue.main.async {
                self.tableView.setContentOffset( .zero , animated: true)
                if self.PostsLoaded.count > 0 {
                    let indexPath = IndexPath(row: 0 , section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    DispatchQueue.main.async {
                        self.tableView.setContentOffset( CGPoint(x: 0, y: 0) , animated: false)
                    }
                }
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    func updateServerUserIdFirebase() {
        
        if let userId = UserDefaultsManager.instance.CurrentUserId() {
            
            let dict:NSDictionary = [kServerUserId:userId,kISONLINE:true]
            
            updateServerUserId(withValues: dict as! [String : Any], completion: {(error)in
                
                if let err = error {
                    print(err.localizedDescription)
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        button.setTitle(AppManager.CategoryName, for: .normal)
        
        //if CategoryLoaded != AppManager.categoryID || AppManager.shouldLoadPostsAgain == true {
        
        if AppManager.shouldUpdateCommentsCount == false {
            self.Page = 1
            AppManager.userposts = []
            self.PostsLoaded = []
            self.CategoryLoaded = AppManager.categoryID
            AppManager.shouldLoadPostsAgain = false
            self.tableView.reloadData()
            
            loadPosts()
        }
        else {
            
            AppManager.shouldUpdateCommentsCount = false
            
            self.tableView.beginUpdates()
            
            let indexpath = IndexPath(row:AppManager.PostindexUpdated,section: 0)
            self.tableView.reloadRows(at: [indexpath], with: .none)
            self.tableView.endUpdates()
            
        }
            
        //}
        //else {
            
         //   self.PostsLoaded = AppManager.userposts
        //    self.tableView.reloadData()
       // }
        let profileImg = UserDefaultsManager.instance.getValueFor(key: KeyProfileImage)
        
        if profileImg != nil {
            
            self.currentUserAvatar.sd_setImage(with: URL(string:profileImg!))
        }
        else {
            
            self.currentUserAvatar.image = UIImage(named: "user (1)")
        }
    }
    
    @objc func selectPostCategories(_ sender:Any) {
        
        print("post Category select")
        
        if let vc =  UIStoryboard(name: "Feeds", bundle: nil).instantiateViewController(withIdentifier: "ShowActivitesViewController") as? ShowActivitesViewController
        {
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
    
    
    //MARK: Load posts
    
    func loadPosts(){
        
        //HUD.show(.rotatingImage(UIImage(named: "progress")))
        
        if request !=  nil {
            
            self.request?.cancel()
            
        }
        self.request = nil
        
        let neighbourHoodId = UserDefaultsManager.instance.getNeighbourHoodId()!
        let userId = UserDefaultsManager.instance.CurrentUserId()!
        
        print("neighbourhood value \(neighbourHoodId)")
        
        
        let url = URL(string:"\(HelperFuntions.loadPosts)?id=\(neighbourHoodId)&page=\(self.Page)&length=\(self.PageLimit)&categoryId=\(AppManager.categoryID)&userId=\(userId)")
        
        print("url is \(url!)" )
        let MyHeader = ["content-type": "application/json"]
        
        self.request = Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
            DispatchQueue.main.async {
                
                // HUD.hide()
                
                switch responseJSON.result{
                    
                case .success(let data):
                    var statusCode:Int = 0
                    if responseJSON.result.value != nil{
                        
                        statusCode = (responseJSON.response?.statusCode)!
                        print("...HTTP code: \(statusCode)")
                    }
                    
                    let recievedCode = data as! NSDictionary
                    
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let status = req.value(forKey: "status") as! Int
                    
                    if status == 1 {
                        
                        if let dict = responseJSON.result.value as? NSDictionary {
                            
                            if let json = JSON(dict.object(forKey: "posts") as Any).array {
                                
                                if self.Page == 1 {
                                    self.PostsLoaded = []
                                    AppManager.userposts = []
                                    
                                }
                                
                                for a in json {
                                    
                                    let obj = post(json:a)
                                    
                                    self.PostsLoaded.append(obj)
                                    AppManager.userposts.append(obj)
                                }
                            }
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                    }
                    
                    self.HasNext = recievedCode.value(forKey: "hasNext") as? Bool ?? false
                    
                case .failure(let error):
                    print(error)
                    //HUD.hide()
                }
                
            }
            
        }
    }
    
    
}
//MARK: - TableView Datasource and Delegate
extension FeedsViewController: UITableViewDelegate, UITableViewDataSource  {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = self.PostsLoaded[indexPath.row]
        
        return getHeightOfCell(desc: post.postMessage!,type: post.postTypeId ?? 1)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.PostsLoaded.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = self.PostsLoaded[indexPath.row]
        
        if post.postTypeId == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TextPostCell.self), for: indexPath) as? TextPostCell ?? TextPostCell()
            cell.selectionStyle = .none
            
            cell.delegate = self
            cell.delegateView = self
            cell.delegateprofileView = self
            cell.populateData(post: post)
            cell.assignTags(indexPath: indexPath)
            
            cell.lblDescription.handleURLTap { url in
                
                let newUrl = url.formatURL()
                UIApplication.shared.open(newUrl, options: [:], completionHandler: nil)
            }
            
            return cell
            
        }
        else if post.postTypeId == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ImagePostCell.self), for: indexPath) as? ImagePostCell ?? ImagePostCell()
            cell.selectionStyle = .none
            cell.delegateActions = self
            cell.delegateView = self
            cell.delegateprofileView = self
            cell.populateData(post: post)
            cell.assignTags(indexPath: indexPath)
            
            cell.lblDescription.handleURLTap { url in
                
                let newUrl = url.formatURL()
                UIApplication.shared.open(newUrl, options: [:], completionHandler: nil)
            }
            
            
            
            return cell
            
        }
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VideoPostCell.self), for: indexPath) as? VideoPostCell ?? VideoPostCell()
            cell.selectionStyle = .none
            cell.delegateView = self
            cell.populateData(post: post)
            cell.delegateFeeds = self
            cell.delegateActions = self
            cell.delegateprofileView = self
            cell.assignTags(indexPath: indexPath)
            
            cell.lblDescription.handleURLTap { url in
                
                let newUrl = url.formatURL()
                UIApplication.shared.open(newUrl, options: [:], completionHandler: nil)
            }
            
            return cell
            
        }
        
        
        
        
        //        if dict["type"] as! Int == 1{
        //            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ImagePostCell.self), for: indexPath) as? ImagePostCell ?? ImagePostCell()
        //            cell.selectionStyle = .none
        //
        //            cell.populateData( image: dict["image"] as! String, desc:  dict["desc"] as! String)
        //            //                   cell.delegate = self
        //            //                   cell.assignTags(indexPath: indexPath)
        //            return cell
        //        }else if dict["type"] as! Int == 2{
        //            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VideoPostCell.self), for: indexPath) as? VideoPostCell ?? VideoPostCell()
        //            cell.selectionStyle = .none
        //
        //            cell.populateData( image: dict["image"] as! String, desc:  dict["desc"] as! String)
        //            cell.delegate = self
        //            cell.assignTags(indexPath: indexPath)
        //            return cell
        //        }else{
        //            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TextPostCell.self), for: indexPath) as? TextPostCell ?? TextPostCell()
        //            cell.selectionStyle = .none
        //
        //            cell.populateData(  desc:  dict["desc"] as! String)
        //
        //            return cell
        //        }
        
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let intTotalrow = tableView.numberOfRows(inSection:indexPath.section)//first get total rows in that section by current indexPath.
        //get last last row of tablview
        if indexPath.row == intTotalrow - 4 {
            
            if HasNext == true {
                
                self.Page = self.Page + 1
                self.loadPosts()
            }
        }
    }
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //
    //
    //    }
    
    func getHeightOfCell(desc:String, type:Int) -> CGFloat{
        let cellContentLeftMargin:CGFloat = 20.0
        let cellContentRightMargin:CGFloat = 20.0
        var cellSubviewsMarginWithEachOther:CGFloat = 60.0
        
        var descriptionHeight = CGFloat(0.0)
        
        if desc == "" {
            descriptionHeight = 10.0
        }
        else {
            
            descriptionHeight = estimatedHeightOfLabel(text: desc)
        }
        
        let frameWidth:CGFloat = self.view.frame.size.width
        
        //image has 16:9 ratio so we are going to calculate the image height according to device width
        let ratio:CGFloat = 16/9
        let imageHeight = (frameWidth - cellContentLeftMargin - cellContentRightMargin) / ratio
        let extraHehit = 120
        if type == 1 {
            cellSubviewsMarginWithEachOther = 40
        }
        
        return   descriptionHeight + ((type != 1) ? imageHeight  : 0) + cellSubviewsMarginWithEachOther + CGFloat(extraHehit)
    }
    
    func estimatedHeightOfLabel(text: String) -> CGFloat {
        
        //getting the height of the label
        let leftMargin:CGFloat = 20.0
        let rightMargin:CGFloat = 20.0
        let size = CGSize(width: view.frame.width - leftMargin - rightMargin, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height
        return rectangleHeight
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        print("changed")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 3
    }
    
    //MARK: Feeds Actions
    
    func LikeButtonPressed(tag: Int) {
        
        //Handle like functionality here
        
        let post = PostsLoaded[tag]
        
        if post.selfLiked == 0 {
            
            PostsLoaded[tag].selfLiked = 1
            self.PostsLoaded[tag].likeCount = (self.PostsLoaded[tag].likeCount!) + 1
        }
        else {
            PostsLoaded[tag].selfLiked = 0
            self.PostsLoaded[tag].likeCount = self.PostsLoaded[tag].likeCount! - 1
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        let url = URL(string:HelperFuntions.PostLikeUnlike)
        
        let params:[String:Any] = ["postId": post.postId!,
                                   "likedByUserId":  UserDefaultsManager.instance.CurrentUserId()]
        
        let MyHeader = ["content-type": "application/json"]
        
        Alamofire.request(url!, method: .post, parameters: params, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
            DispatchQueue.main.async{
                
                switch responseJSON.result{
                case .success(let data):
                    print("res..\(responseJSON)")
                    
                    let recievedCode = data as! NSDictionary
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    print("successed")
                    
                case .failure(let error):
                    print("Failed...\(error)")
                    
                }
            }
            
        }
        
    }
    
    func CommentButtonPressed(tag: Int) {
        let post = PostsLoaded[tag]
        
        
        if let vc =  UIStoryboard(name: "Feeds", bundle: nil).instantiateViewController(withIdentifier: "PresentViewController") as? PresentViewController
        {
            vc.userPostID = post.postId
            vc.postIndex = tag
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func DidSelectReportPost(tag: Int) {
        
        let post = PostsLoaded[tag]
        
        ShowPostActionAlert(post: post,index:tag)
    }
    
    func ShowPostActionAlert(post: post,index: Int) {
        
        let alert:UIAlertController=UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let reportAction = UIAlertAction(title: "Report Post", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            
            print("Report")
            self.ReportPost(post: post)
        }
        
        alert.addAction(reportAction)
        
        let userId = UserDefaultsManager.instance.CurrentUserId()
        let owner =  post.CreatedByUser.usersId
        
        if userId == owner {
            
            let deleteAction = UIAlertAction(title: "Delete Post", style: UIAlertAction.Style.default)
            {
                UIAlertAction in
                
                self.DeletePost(post:post,index: index )
            }
            alert.addAction(deleteAction)
        }
        
        
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
            
            print("Cancel")
        }
        
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func didSelectPlayVideo(tag: Int) {
        let post = PostsLoaded[tag]
        let videoURL = URL(string: (post.content?[0].path!)!)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func didSelectViewImage(image: UIImage ) {
        
        let imageInfo = GSImageInfo(image: image, imageMode: .aspectFit, imageHD: nil)
        let transitionInfo = GSTransitionInfo(fromView: self.tableView)
        let imageViewer    = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        present(imageViewer, animated: true, completion: nil)
        
    }
    func didSelectProfileName(tag: Int) {
        
        let post = PostsLoaded[tag]
        let userID = post.CreatedByUser.usersId
        let userName = post.CreatedByUser.fullName
        let profilePic =  post.CreatedByUser.profileImage
        if let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "UserInfoViewController") as? UserInfoViewController
        {
            vc.userID =  userID!
            vc.userName =  userName!
            vc.isloggedInUser = false
            vc.profileImage =  profilePic
            AppManager.globalCheck = 2
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func createFeedButtonPressed(_ sender: RoundButtonWithBorderColor) {
        
        if let vc =  UIStoryboard(name: "Feeds", bundle: nil).instantiateViewController(withIdentifier: "CreateFeeds") as? CreateFeeds
        {
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    //MARK: title Bar Setup
    
    func setupTitleBar() {
        
        
        button.frame =  CGRect(x: 0, y: 0, width: 200, height: 40)
        button.tintColor = UIColor.white
        button.setImage(UIImage(named:"Dropdown icon"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 6,left: 0,bottom: 6,right: 34)
        button.titleEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 14)
        
        button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.titleLabel?.font = UIFont(name: "Open Sans", size: 16)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.selectPostCategories(_:)))
        button.addGestureRecognizer(tap)
        
        let view = UIStackView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 0
        view.addArrangedSubview(button)
        
        let mainTitleView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        mainTitleView.addSubview(view)
        
        navigationItem.titleView = mainTitleView
        
    }
    
    @objc func refresh(_ sender:AnyObject) {
        
        self.Page = 1
        //PostsLoaded = []
        //AppManager.userposts = []
        loadPosts()
        
        
    }
    
    func setUserPresenceStatus() {
        
        // since I can connect from multiple devices, we store each connection instance separately
        // any time that connectionsRef's value is null (i.e. has no children) I am offline
        let myConnectionsRef = Database.database().reference(withPath: "user/" + FUser.currentId())
        
        // stores the timestamp of my last disconnect (the last time I was seen online)
        let lastOnlineRef = Database.database().reference(withPath: "user/" + FUser.currentId() + "/lastOnline")
        
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        
        connectedRef.observe(.value, with: { snapshot in
            // only handle connection established (or I've reconnected after a loss of connection)
            guard let connected = snapshot.value as? Bool, connected else { return }
            
            // add this device to my connections list
            let con = myConnectionsRef.child("status")
            
            // when this device disconnects, remove it.
            con.onDisconnectSetValue(false)
            
            // The onDisconnect() call is before the call to set() itself. This is to avoid a race condition
            // where you set the user's presence to true and the client disconnects before the
            // onDisconnect() operation takes effect, leaving a ghost user.
            
            // this value could contain info about the device or a timestamp instead of just true
            con.setValue(true)
            
            // when I disconnect, update the last time I was seen online
            lastOnlineRef.onDisconnectSetValue(ServerValue.timestamp())
        })
    }
    
    
    func ReportPost(post: post) {
        
        let postId = post.postId!
        let userId = UserDefaultsManager.instance.CurrentUserId()!
        
        let url = URL(string:"\(HelperFuntions.reportPost)")
        let postString = ["userId": userId, "postId" : postId] as [String : Any]
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
                    
                    let status = recievedCode.value(forKey: "status") as! Int
                    let result = recievedCode.value(forKey: "result") as! Int
                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1 && result == 1{
                            
                            self.DisplayMessage(userMessage: "This post has been reported to Hayi Team", title: "Reported")
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
    
    func DeletePost(post: post,index: Int) {
        
        let postId = post.postId!
        
        let url = URL(string:"\(HelperFuntions.DeletePost)")
        let postString = ["id": postId] as [String : Any]
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
                    
                    let indexPath = IndexPath(item: index, section: 0)
                    
                    self.PostsLoaded.remove(at: index)
                    
                    self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                    
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
    
    
}


