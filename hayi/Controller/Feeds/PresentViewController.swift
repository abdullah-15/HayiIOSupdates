//
//  PresentViewController.swift
//  hayi-ios2
//
//  Created by Mohsin on 03/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.

import UIKit
import Alamofire
import PKHUD
import SwiftyJSON
import AVKit
import AVFoundation
import GSImageViewerController

class PresentViewController: UIViewController , UITableViewDataSource , UITableViewDelegate, FeedsViewCellDelegate,FeedsViewImageDelegate,PostActionsDelegate,ProfileViewDelegate,PresentTableViewCellDelegate,UITextViewDelegate{

    @IBOutlet weak var sendMessageContainerHeight: NSLayoutConstraint!
    
    var userPostID : Int?
    var allpost : Allpost?
    var allPostComments = [AllPostComments]()
    var postIndex: Int?
    @IBOutlet weak var writeComment: UITextView!
    var commented = [String]()
    
    var PostsLoaded = [post]()
    
    @IBOutlet weak var present: UITableView!
    @IBOutlet weak var postDetailsTable: UITableView!
    
    @IBOutlet weak var presentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var parentScrollView: UIScrollView!
    @IBOutlet weak var parentView: NSLayoutConstraint!
    @IBOutlet weak var superParentView: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        present.delegate = self
        present.dataSource = self
        self.postDetailsTable.delegate = self
        self.postDetailsTable.dataSource = self
        writeComment.autocapitalizationType = .sentences
        let yourBackImage = UIImage(named: "Back")
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        self.view.layoutIfNeeded()
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        // Set automatic dimensions for row height
        // Swift 4.2 onwards
        present.rowHeight = UITableView.automaticDimension
        present.estimatedRowHeight = UITableView.automaticDimension
        
        self.postDetailsTable.separatorColor = UIColor.clear
        
        self.postDetailsTable.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        getPostWithDetail()
        
        self.tabBarController?.tabBar.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)),  name:  UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)),  name: UIResponder.keyboardDidShowNotification, object: nil)
        
        self.writeComment.placeholder = "Write Something"
        self.writeComment.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if self.allPostComments.count > 2 {
            let indexPath = IndexPath(row: self.allPostComments.count-1, section: 0)
            self.present.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        
        AppManager.shouldUpdateCommentsCount = true
    }
    
     func updateParentViewHeight() {
        
        self.updateViewConstraints()
    }
    
    @objc func keyboardDidShow(_ notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (userInfo.object(forKey: UIResponder.keyboardFrameEndUserInfoKey)! as AnyObject).cgRectValue.size
        
        //calculate the space it needs to show the firstResponder textField completely
        var difference: CGFloat
        if writeComment.isFirstResponder == true {
            difference = keyboardSize.height - (self.view.frame.height - writeComment.frame.origin.y - writeComment.frame.size.height)
        }
        else {
            difference = keyboardSize.height - (self.view.frame.height - writeComment.frame.origin.y - writeComment.frame.size.height)
        }
        //if the textField frame under the keyboard, so scroll up to show it
                    
       // self.parentScrollView.frame = CGRect (x: 0,y: 0,width: self.view.frame.size.height,height: 500)
        //self.parentScrollView.scr
            // var contentInset:UIEdgeInsets = self.parentScrollView.contentInset
           // contentInset.bottom = difference
//            self.parentScrollView.contentInset = contentInset
//
            //let scrollPoint = CGPoint(x: 0, y: difference)
            //self.parentScrollView.setContentOffset(scrollPoint, animated: true)
            
           
            
        //}
        
    }
    
    @objc func keyboardDidHide(_ notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
   //     self.parentScrollView.contentInset = contentInset
    //    parentViewHeight.constant = self.view.frame.size.height
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.updateViewConstraints()
    }
    
    private func validateContactUsFields()-> Bool {
        
        if !HelperFuntions.validateRequiredField(writeComment.text!){
            
            HelperFuntions.showAlert("Erorr", withMessage: "Please enter comment.")
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == present {
            return self.allPostComments.count
        }
        else {
            return self.PostsLoaded.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == present {
            
            let comment = self.allPostComments[indexPath.row]
            
            print("Heigth")
            
            print(estimatedHeightOfLabel(text: comment.comment!))
            
            return 70 + estimatedHeightOfLabel(text: comment.comment!)
        }
        else {
            let post = self.PostsLoaded[0]
            if post.postTypeId == 1 {
                
                return 164 + estimatedHeightOfLabel(text: post.postMessage!)
            }
            else {
                
                print("post \(estimatedHeightOfLabel(text: post.postMessage!) * 2) ")
                var labelHeight:CGFloat = 10.0
                if post.postMessage != "" {
                    labelHeight = labelHeight + (estimatedHeightOfLabel(text: post.postMessage!))
                }
                
                
                return 180 + labelHeight  + 210
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == present {
            
            let cellA = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PresentTableViewCell
            
            let comment = self.allPostComments[indexPath.row]
            
            cellA.commentedText.text = comment.comment
            
            if comment.createdAt != nil {
                
                let dateFormatterGet =  dateFormatter2()
                
                let truncatedDate =  comment.createdAt!.components(separatedBy: ".")[0]
                
                let date: Date? = dateFormatterGet.date(from: truncatedDate)
                
                cellA.commentedTime.text = dayElapsedData(date: date!)
            }
            cellA.profileName.text = comment.fullName
            
            if comment.profileImage == "" || comment.profileImage == nil {
                
                cellA.profileImage.image = UIImage(named: "user icon(1)")
            }
            else {
                cellA.profileImage.kf.setImage(with: URL(string:comment.profileImage!))
            }
            cellA.commentedText.isUserInteractionEnabled = true
            
            cellA.commentedText.handleURLTap { url in
                
                let newUrl = url.formatURL()
                UIApplication.shared.open(newUrl, options: [:], completionHandler: nil)
            }
            cellA.assignTags(indexPath: indexPath)
            cellA.delegate = self
            
            return cellA
        }
        else {
            
            let post = self.PostsLoaded[indexPath.row]
            
            if post.postTypeId == 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DTextPostCell.self), for: indexPath) as? DTextPostCell ?? DTextPostCell()
                cell.selectionStyle = .none
                
                cell.delegate = self
                cell.delegateView = self
                cell.delegateprofileView = self
                cell.populateData(post: post)
                cell.assignTags(indexPath: indexPath)
                
                cell.lblDescription.isUserInteractionEnabled = true
                cell.lblDescription.handleURLTap { url in
                   let newUrl = url.formatURL()
                    UIApplication.shared.open(newUrl, options: [:], completionHandler: nil)
                }
                
                
                
                
                return cell
                
            }
            else if post.postTypeId == 2 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DImagePostCell.self), for: indexPath) as? DImagePostCell ?? DImagePostCell()
                cell.selectionStyle = .none
                cell.delegateActions = self
                cell.delegateView = self
                cell.delegateprofileView = self
                cell.populateData(post: post)
                cell.assignTags(indexPath: indexPath)
                
                cell.lblDescription.isUserInteractionEnabled = true
                
                cell.lblDescription.handleURLTap { url in
                    let newUrl = url.formatURL()
                    UIApplication.shared.open(newUrl, options: [:], completionHandler: nil)
                }
                
                return cell
                
            }
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DVideoPostCell.self), for: indexPath) as? DVideoPostCell ?? DVideoPostCell()
                cell.selectionStyle = .none
                cell.delegateView = self
                cell.populateData(post: post)
                cell.delegateFeeds = self
                cell.delegateActions = self
                cell.delegateprofileView = self
                cell.assignTags(indexPath: indexPath)
                
                cell.lblDescription.isUserInteractionEnabled = true
                cell.lblDescription.handleURLTap { url in
                    let newUrl = url.formatURL()
                    UIApplication.shared.open(newUrl, options: [:], completionHandler: nil)
                }
                return cell
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            
            let value = self.allPostComments[indexPath.row].postCommentsId
            DeletePostComment(commentID: value!)
            print("Deleted Values is == \(value!)")
            self.allPostComments.remove(at: indexPath.row)
            self.present.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        
        if tableView == present {
            
            let userId = UserDefaultsManager.instance.CurrentUserId()
            
            if self.allPostComments[indexPath.row].commentByUserId! == userId {
                return UITableViewCell.EditingStyle.delete
            }
        }
        
        return UITableViewCell.EditingStyle.none
        
    }
    
    func estimatedHeightOfLabel(text: String) -> CGFloat {
        
        //getting the height of the label
        let leftMargin:CGFloat = 10.0
        let rightMargin:CGFloat = 10.0
        
        let width = (view.frame.width / 100) * 85
        
        let size = CGSize(width: width  - leftMargin - rightMargin, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height
        return rectangleHeight
    }
    //remove if no error
//    @IBAction func addSmile(_ sender: Any) {
//
//
//    }
    
    private func createPostComment(){
        
        let postCommentsId =  0
        let comment: String? = self.writeComment.text!
        let profileImage : String? = UserDefaultsManager.instance.getValueFor(key: KeyProfileImage)
        let fullName :String? = (UserDefaultsManager.instance.getValueFor(key: KeyFirstName) ?? "") + " " + (UserDefaultsManager.instance.getValueFor(key: KeyLastName) ?? "")
        let commentByUserId = UserDefaultsManager.instance.CurrentUserId()
        
        let obj = AllPostComments(postCommentsId: postCommentsId, comment: comment, profileImage: profileImage, fullName: fullName, commentByUserId: commentByUserId)
        
        self.allPostComments.append(obj)
        
        
        
        DispatchQueue.main.async {
            
            self.present.reloadData()
            self.updateParentViewHeight()
            
            if self.allPostComments.count > 0 {
                
                let indexPath = IndexPath(row: self.allPostComments.count-1, section: 0)
                self.present.scrollToRow(at: indexPath, at: .bottom, animated: true)
                
                if let index = self.postIndex {
                    
                    AppManager.userposts[index].commentCount =  (AppManager.userposts[index].commentCount ?? 0) + 1
                    AppManager.PostindexUpdated = index
                    AppManager.shouldUpdateCommentsCount = true
                }
            }
        }
        
        let url = URL(string:"\(HelperFuntions.createPostComment)")
        
        let postring = ["comment" : writeComment.text!,
                        "commentHtml" : "",
                        "postId" : userPostID!,
                        "commentByUserId" : UserDefaults.standard
                            .value(forKey: "userID")!] as [String : Any]
        print("post comemnt \(postring)")
        
        
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
                    
                    let recievedCode = data as! NSDictionary
                    
                    // let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let result = recievedCode.value(forKey: "result") as! Bool
                    let status = recievedCode.value(forKey: "status") as! Int
                    let message = recievedCode.value(forKey: "msg") as! String
                    
                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1 && result == true {
                            // self.dismiss(animated: true, completion: nil)
                            self.writeComment.text = ""
                            
                            self.sendMessageContainerHeight.constant = 40
                            
                            // self.DisplayMessage(userMessage: "Successfully Post Comment", title: "Alert")
                            NotificationCenter.default.post(name: Notification.Name("loadBreakfast"), object: nil)
                            self.dismiss(animated: true, completion: nil)
                            
                            self.present.reloadData()
                            self.updateParentViewHeight()
                            
                            
                            
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
    
    private func getPostWithDetail(){
        
        
        let userId =  UserDefaultsManager.instance.CurrentUserId()!
        
        
        let url = URL(string:"\(HelperFuntions.getPostDetailsByID)?id=\(userPostID!)&userId=\(userId)")
        
        let MyHeader = ["content-type": "application/json"]
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
            DispatchQueue.main.async {
                
                switch responseJSON.result {
                    
                case .success(let data):
                    
                    var statusCode:Int = 0
                    if responseJSON.result.value != nil{
                        
                        statusCode = (responseJSON.response?.statusCode)!
                        print("...HTTP code: \(statusCode)")
                    }
                    
                    print(data)
                    
                    HUD.hide()
                    
                    if let res = responseJSON.result.value as? NSDictionary
                    {
                        
                        let dict = res
                        
                        
                        let json = JSON(dict.object(forKey: "post") as Any)
                        
                        self.allpost = Allpost(json: json)
                        let postobj  = post(json:json)
                        self.PostsLoaded.append(postobj)
                        self.postDetailsTable.reloadData()
                        self.updateParentViewHeight()
                        
                        
                        if let json = JSON(dict.object(forKey: "postComments") as Any).array {
                            
                            for a in json {
                                let obj = AllPostComments(json: a)
                                self.allPostComments.append(obj)
                            }
                        }
                        
                        self.present.reloadData()
                        self.updateParentViewHeight()
                        
                        
                        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    private func DeletePostComment(commentID : Int){
        //HUD.show(.rotatingImage(UIImage(named: "progress")))
        let url = URL(string:"\(HelperFuntions.deletePostComment)")
        
        let postring = ["id" :commentID] as [String : Any]
        
        print("post comemnt \(postring)")
        
        
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
                    
                    let status = recievedCode.value(forKey: "status") as! Int
                    let result = recievedCode.value(forKey: "result") as! Bool
                    let message = recievedCode.value(forKey: "msg") as! String
                    
                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1 && result == true{
                            self.dismiss(animated: true, completion: nil)
                            self.writeComment.text = ""
                            
                            // self.DisplayMessage(userMessage: message, title: "Deleted")
                            
                            
                            
                            
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
    
    override func updateViewConstraints() {
        //self.parentView.constant = self.postDetailsTable.contentSize.height
        
        
        UIView.animate(withDuration: 0, animations: {
            self.postDetailsTable.layoutIfNeeded()
        }) { (complete) in
            var heightOfTableView: CGFloat = 0.0
            // Get visible cells and sum up their heights
            let cells = self.postDetailsTable.visibleCells
            for cell in cells {
                heightOfTableView += cell.frame.height
                print("cell \(heightOfTableView)")
            }
            self.parentView.constant = heightOfTableView
        }
        
        UIView.animate(withDuration: 0, animations: {
            self.present.layoutIfNeeded()
        }) { (complete) in
//            var heightOfTableView: CGFloat = 0.0
//            // Get visible cells and sum up their heights
//            let cells = self.present.visibleCells
//            for cell in cells {
//                heightOfTableView += cell.frame.height
//                print("cell \(heightOfTableView)")
//            }
//            self.presentHeightConstraint.constant = heightOfTableView
            self.presentHeightConstraint.constant = self.calculatePresentHeight()
        }
        
        
        
        if self.presentHeightConstraint.constant < 300 {
        
            self.presentHeightConstraint.constant = 500
        }
//        self.superParentView.constant = self.presentHeightConstraint.constant + self.parentView.constant + 80
        super.updateViewConstraints()
    }
    
    private func calculatePresentHeight() -> CGFloat{
        var height: CGFloat = 0.0
        for comment in allPostComments {
            height = height + 70.0 + estimatedHeightOfLabel(text: comment.comment!)
        }
        
        return height
    }
    
    func DisplayMessage(userMessage:String , title: String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: userMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default){(
                ACTION:UIAlertAction!) in
                //self.emptyAllTextFields()
                self.dismiss(animated: true, completion: nil)
                
                
            }
            let addMoreComment = UIAlertAction(title: "Comment", style: .default){(
                ACTION:UIAlertAction!) in
                //self.emptyAllTextFields()
                
            }
            alertController.addAction(okAction)
            alertController.addAction(addMoreComment)
            
            
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func Display(userMessage:String , title: String) -> Void {
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
    
    @IBAction func sendBtn(_ sender: Any) {
        if validateContactUsFields() {
            if Connectivity.isConnectedToInternet(){
                createPostComment()
            }else{
                self.Display(userMessage: internetNot, title: "Info")
            }
        }
    }
    
    //MARK: Feeds Actions
    
    func LikeButtonPressed(tag: Int) {
        
        //Handle like functionality here
        
        AppManager.shouldLoadPostsAgain = true
        
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
            self.postDetailsTable.reloadData()
            self.updateParentViewHeight()
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
        
        AppManager.shouldLoadPostsAgain = true
        
        if self.allPostComments.count > 0 {
            
            let indexPath = IndexPath(row: self.allPostComments.count - 1, section: 0)
            self.present.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        
        self.writeComment.becomeFirstResponder()
        
    }
    
    func DidSelectReportPost(tag: Int) {
        
        let post = PostsLoaded[tag]
        
        ShowPostActionAlert(post: post)
        
    }
    
    func ShowPostActionAlert(post: post) {
        
        let alert:UIAlertController=UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let reportAction = UIAlertAction(title: "Report Post", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            
            print("Report")
            self.ReportPost(post: post)
        }
        
        alert.addAction(reportAction)
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
            
            print("Cancel")
        }
        
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func didSelectProfileImageComments(Image: UIImage) {
        
        let imageInfo = GSImageInfo(image: Image, imageMode: .aspectFit, imageHD: nil)
        let transitionInfo = GSTransitionInfo(fromView: self.postDetailsTable)
        let imageViewer    = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        present(imageViewer, animated: true, completion: nil)
    }
    
    func didSelectProfileNameComments(Tag: Int) {
        
        let comment = self.allPostComments[Tag]
        let userID = comment.commentByUserId
        let userName = comment.fullName
        let profilePic =  comment.profileImage
        
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
        let transitionInfo = GSTransitionInfo(fromView: self.postDetailsTable)
        let imageViewer    = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        present(imageViewer, animated: true, completion: nil)
        
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
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != ""{
            textView.placeholder = ""
        }
        else {
            textView.placeholder = "Write Something"
        }
          let fixedWidth = textView.frame.size.width
          textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
          let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
          var newFrame = textView.frame
          newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
          textView.frame = newFrame
        sendMessageContainerHeight.constant =  textView.frame.height + 8
        self.view.layoutIfNeeded()
    }

}
