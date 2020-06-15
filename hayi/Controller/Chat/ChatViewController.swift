import UIKit
import MessageKit
import Firebase
import InputBarAccessoryView
import AVFoundation
import AVKit
import Kingfisher
import GSImageViewerController
import Alamofire
import SwiftyJSON
import IQKeyboardManagerSwift

class ChatViewController: MessagesViewController,MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate,InputBarAccessoryViewDelegate {
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var messages = [MessageKitMessage]()
    
    var user = MessageKitUser(senderId: FUser.currentId(), displayName:  UserDefaultsManager.instance.getFullName())
    let refreshControl = UIRefreshControl()
    
    var withUsers: [FUser] = []
    
    var chatRoomId: String!
    var memberIds: [String]!
    var membersToPush: [String]!
    var memberstoFCMPush: [String]!
    var titleName: String!
    var isGroup: Bool?
    var group: NSDictionary?
    var screenHeight:CGFloat = 896
    
    let legitTypes = [kAUDIO, kVIDEO, kTEXT, kLOCATION, kPICTURE]
    
    var initialLoadComplete = false
    
    var messageCollectionViewFrame:CGRect?
    
    var typingListener: ListenerRegistration?
    var UserStatusListener: ListenerRegistration?
    var updatedChatListener: ListenerRegistration?
    var newChatListener: ListenerRegistration?
    
    var typingCounter = 0
    
    var maxMessageNumber = 0
    var minMessageNumber = 0
    var loadOld = false
    var loadedMessagesCount = 0
    
    var fectchingMore = true
    
    
    var loadedMessages: [NSDictionary] = []
    var advanceLoadedMessages: [NSDictionary] = []
    var allPictureMessages: [String] = []
    
    var jsqAvatarDictionary: NSMutableDictionary?
    
    var avatarImageDictionary: NSMutableDictionary?
    var showAvatars = true
    var firstLoad: Bool?
    
    var senderId: String = ""
    var senderDisplayName: String = ""
    
    
    var messageCollectionViewBottomInset: CGFloat = 0 {
        didSet {
            messagesCollectionView.contentInset.bottom = messageCollectionViewBottomInset
            messagesCollectionView.scrollIndicatorInsets.bottom = messageCollectionViewBottomInset
        }
    }
    
    var messageCollectionViewBottomInsetAttachment:CGFloat = 0
    /// The object that manages attachments
    open lazy var attachmentManager: AttachmentManager = { [unowned self] in
        let manager = AttachmentManager()
        manager.delegate = self
        return manager
        }()
    
    /// The object that manages autocomplete
    open lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.messageInputBar.inputTextView)
        manager.delegate = self
        manager.dataSource = self
        return manager
        }()
    
    
    let leftBarButtonView: UIView = {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        return view
    }()
    let avatarButton: UIButton = { 
        let button = UIButton(frame: CGRect(x: 0, y: 10, width: 25, height: 25))
        return button
    }()
    let titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 30, y: 10, width: 140, height: 15))
        title.textAlignment = .left
        title.font = UIFont(name: title.font.fontName, size: 14)
        return title
    }()
    let subTitleLabel: UILabel = {
        let subTitle = UILabel(frame: CGRect(x: 30, y: 25, width: 140, height: 15))
        subTitle.textAlignment = .left
        subTitle.font = UIFont(name: subTitle.font.fontName, size: 10)
        
        return subTitle
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        
        clearRecentCounter(chatRoomId: chatRoomId)
        getUsersFromFirestore(withIds: memberIds) { (withUsers) in
            
            self.withUsers = withUsers
            //  self.getAvatarImages()
            self.setupTitleView()
            self.updateTitleView(title: withUsers[0].fullname, subtitle: withUsers[0].isOnline ? "Online":"")
            self.createUserStatusObserver()
            
        }
        let notifier = NotificationCenter.default
        notifier.addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: UIWindow.keyboardDidShowNotification, object: nil)

            notifier.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIWindow.keyboardDidHideNotification, object: nil)
        
    }
    
    
    @objc func keyboardDidShow(_ notification: NSNotification) {
        print("keyboardDidShow")
        
        guard let keyboardEndFrameInScreenCoords = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardEndFrame = view.convert(keyboardEndFrameInScreenCoords, from: view.window)
        
        let newBottomInset = requiredScrollViewBottomInset1(forKeyboardFrame: keyboardEndFrame)
        let differenceOfBottomInset = newBottomInset - messageCollectionViewBottomInset + messageCollectionViewBottomInsetAttachment
        
        if attachmentManager.attachments.count > 0 {
            print("there is attachment in view")
            
            if(messageCollectionViewBottomInsetAttachment == 0) {
                print("IN If")
                messageCollectionViewBottomInsetAttachment = self.messageInputBar.frame.height + 148
            }
            else {
                print("In Else")
                if messageCollectionViewBottomInsetAttachment > 0 {
                    messageCollectionViewBottomInsetAttachment = self.messageInputBar.frame.height - 15
                }
            }
//            messageCollectionViewBottomInsetAttachment = (messageCollectionViewBottomInsetAttachment - self.messageInputBar.frame.height ) * -1
            
            messagesCollectionView.scrollIndicatorInsets.bottom = messageCollectionViewBottomInsetAttachment
            messagesCollectionView.contentInset.bottom = messageCollectionViewBottomInsetAttachment
         
        }
        else {
            
            print("In bigger else")
            
            if differenceOfBottomInset != 0 {
                
                print("In bigger else's if")
                
                let contentOffset = CGPoint(x: messagesCollectionView.contentOffset.x, y: messagesCollectionView.contentOffset.y + differenceOfBottomInset + messageCollectionViewBottomInsetAttachment)
                messagesCollectionView.setContentOffset(contentOffset, animated: false)
            }
            self.messagesCollectionView.layoutIfNeeded()
            messageCollectionViewBottomInset = newBottomInset
        }
        self.messagesCollectionView.scrollToBottom()

    }
    override func viewSafeAreaInsetsDidChange(){
        print("safe Area inset changed")
    }
    
    private func requiredScrollViewBottomInset1(forKeyboardFrame keyboardFrame: CGRect) -> CGFloat {
        // we only need to adjust for the part of the keyboard that covers (i.e. intersects) our collection view;
        // see https://developer.apple.com/videos/play/wwdc2017/242/ for more details
        let intersection = messagesCollectionView.frame.intersection(keyboardFrame)
        
        if intersection.isNull || (messagesCollectionView.frame.maxY - intersection.maxY) > 0.001 {
            // The keyboard is hidden, is a hardware one, or is undocked and does not cover the bottom of the collection view.
            // Note: intersection.maxY may be less than messagesCollectionView.frame.maxY when dealing with undocked keyboards.
            return max(0, additionalBottomInset - automaticallyAddedBottomInset)
        } else {
            if (messageCollectionViewBottomInset > 100) {
                return max(0, intersection.height + additionalBottomInset - (automaticallyAddedBottomInset))
            }
            return max(0, intersection.height + additionalBottomInset - (automaticallyAddedBottomInset ))
        }
    }
    
    @objc func keyboardDidHide(_ notification: NSNotification){
        
        print("keyboardDidHide")
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        clearRecentCounter(chatRoomId: chatRoomId)
        removeListeners()
    }
    

    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificatonArrived(_:)), name: NSNotification.Name(rawValue: "newnotification"), object: nil)
        
        let objectId = FUser.currentId()
        var ids = ""
        if objectId == self.membersToPush[1] {
             ids = self.membersToPush[0]
        }
        else {
            ids = self.membersToPush[1]
        }
        
        self.getFCMTokensByExternalChatIds(ids: ids)
        
        self.screenHeight =  self.view.frame.height
        
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = true
        view.backgroundColor = .white
        
        view.addSubview(messagesCollectionView)
        
        messagesCollectionView.delegate = self
        messagesCollectionView.dataSource = self
        
        messagesCollectionView.register(HeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        
        configureMessageInputBar()
        configureMessageCollectionView()
        loadMessages()
        
        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()!.fullname
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        print("Chat Room" + chatRoomId)
        
    }
    override func viewDidLayoutSubviews() {
        //super.viewDidLayoutSubviews()
        
        let navigationBarInset = navigationController?.navigationBar.frame.height ?? 0
              let statusBarInset: CGFloat = UIApplication.shared.isStatusBarHidden ? 0 : 20
              let topInset = navigationBarInset + statusBarInset
              messagesCollectionView.contentInset.top = topInset
              messagesCollectionView.scrollIndicatorInsets.top = topInset
        
        
        if attachmentManager.attachments.count > 0 {
            messagesCollectionView.contentInset.bottom = 100
        }
        //self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        createTypingObserver()
        if self.initialLoadComplete {
            self.listenForNewChats()
        }
        self.view.layoutSubviews()

    }
    
    @objc func backButtonTapped(sender: AnyObject){
        
        self.navigationController?.popViewController(animated: false)
    }
    @objc func logoImageTapped(sender: AnyObject){
        
        let user = withUsers[0]
        
        let userID = user.serverUserId
        let userName = user.fullname
        let profilePic =  user.avatar
        if let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "UserInfoViewController") as? UserInfoViewController
        {
            vc.userID =  userID
            vc.userName =  userName
            vc.isloggedInUser = false
            vc.profileImage =  profilePic
            AppManager.globalCheck = 2
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        //self.navigationController?.popViewController(animated: false)
    }
    @objc func TitleTapped(sender: AnyObject){
        
        print("Title View Tapped")
        let user = withUsers[0]
        
        let userID = user.serverUserId
        let userName = user.fullname
        let profilePic =  user.avatar
        if let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "UserInfoViewController") as? UserInfoViewController
        {
            vc.userID =  userID
            vc.userName =  userName
            vc.isloggedInUser = false
            vc.profileImage =  profilePic
            AppManager.globalCheck = 2
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    //MARK: Send Messages
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String){
        
        inputBar.invalidatePlugins()
        
        self.messageInputBar.sendButton.startAnimating()
        
        print(inputBar.inputTextView.text!)
        
        if attachmentManager.attachments.count > 0 {
            
            var ImageItems = [UIImage]()
            
            var i = 0
            let total = attachmentManager.attachments.count
            while i < total {
                let attachment = attachmentManager.attachments[i]
                
                switch attachment {
                case .image(let image):
                    ImageItems.append(image)
                case .url(_):
                    print("its url")
                case .data(_):
                    print("its data")
                case .other(_):
                    print("its something else")
                }
                if inputBar.inputTextView.text != "" {
                    
                    sendMessage(text: inputBar.inputTextView.text , date: Date(), picture: ImageItems[i], location: nil, video: nil, audio: nil, completion: { (isSucces) in
                        for token in self.memberstoFCMPush {
                            self.sendPushNotification(to: token, title: self.senderDisplayName,body: inputBar.inputTextView.text, profileUrl: self.withUsers[0].avatar )
                        }
                    })
                    
                    inputBar.inputTextView.text = ""
                    
                  
                }
                else {
                    sendMessage(text: nil, date: Date(), picture: ImageItems[i], location: nil, video: nil, audio: nil, completion: { (isSucces) in
                        for token in self.memberstoFCMPush {
                            self.sendPushNotification(to: token, title: self.senderDisplayName,body: "[\(kPICTURE)]" , profileUrl: self.withUsers[0].avatar )
                        }
                    })
                    
                 
                }
                
                i = i + 1
            }
            self.attachmentManager.invalidate()
            
        }
        else {
            
            if inputBar.inputTextView.text != "" {
                
                sendMessage(text: inputBar.inputTextView.text!, date: Date(), picture: nil, location: nil, video: nil, audio: nil, completion: { (isSucces) in
                    for token in self.memberstoFCMPush {
                        self.sendPushNotification(to: token, title:self.senderDisplayName, body: inputBar.inputTextView.text , profileUrl: self.withUsers[0].avatar)
                    }
                })
                
                inputBar.inputTextView.text = ""
                
            }
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        
        typingCounterStart()
        
        
    }
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        
        if messageInputBar.inputTextView.text == "" {

            self.messageInputBar.inputTextView.frame.size.height = 80
        }
    }
    
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?, completion : @escaping (Bool)->()) {
        
        var outgoingMessage: OutgoingMessage?
        let currentUser = FUser.currentUser()!
        var messageId: String?
        
        //text with picture
        
        if  text != nil && picture != nil {
            
            
            uploadImage(image: picture!, chatRoomId: chatRoomId, view: self.navigationController!.view) { (imageLink) in
                
                if imageLink != nil {
                    
                    let ecryptedText = Encryption.encryptText(chatRoomId: self.chatRoomId, message: "[\(kPICTURE)]")
                    
                    outgoingMessage = OutgoingMessage(message: ecryptedText, pictureLink: imageLink!, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kPICTURE)
                    
                    messageId = outgoingMessage?.sendMessage(chatRoomID: self.chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        
                        let ecryptedTextM = Encryption.encryptText(chatRoomId: self.chatRoomId, message: text!)
                        
                        outgoingMessage = OutgoingMessage(message: ecryptedTextM, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
                        
                        messageId = outgoingMessage!.sendMessage(chatRoomID: self.chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush)
                    }
                    
                    
                    DispatchQueue.main.async {
                        completion(true)
                        self.messageInputBar.sendButton.stopAnimating()
                    }
                }
                
            }
            
            DispatchQueue.main.async {
                self.messageInputBar.sendButton.stopAnimating()
            }
            
            return
        }
        
        //text message
        if let text = text {
            
            let ecryptedText = Encryption.encryptText(chatRoomId: chatRoomId, message: text)
            
            outgoingMessage = OutgoingMessage(message: ecryptedText, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
            
            completion(true)
        }
        
        //picture message
        
        if let pic = picture {
            
            uploadImage(image: pic, chatRoomId: chatRoomId, view: self.navigationController!.view) { (imageLink) in

                if imageLink != nil {
                    
                    let ecryptedText = Encryption.encryptText(chatRoomId: self.chatRoomId, message: "[\(kPICTURE)]")
                    
                    outgoingMessage = OutgoingMessage(message: ecryptedText, pictureLink: imageLink!, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kPICTURE)
                    
                    messageId = outgoingMessage?.sendMessage(chatRoomID: self.chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush)
                    DispatchQueue.main.async {
                        completion(true)
                        self.messageInputBar.sendButton.stopAnimating()
                    }
                }
                
            }
            return
        }
        
        //send video
        
        if let video = video {
            
            let videoData = NSData(contentsOfFile: video.path!)
            
            let dataThumbnail = videoThumbnail(video: video).jpegData(compressionQuality: 0.3)
            
            uploadVideo(video: videoData!, chatRoomId: chatRoomId, view: self.navigationController!.view) { (videoLink) in
                
                if videoLink != nil {
                    
                    let ecryptedText = Encryption.encryptText(chatRoomId: self.chatRoomId, message: "[\(kVIDEO)]")
                    
                    outgoingMessage = OutgoingMessage(message: ecryptedText, video: videoLink!, thumbNail: dataThumbnail! as NSData, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kVIDEO)
                    
                    messageId =   outgoingMessage?.sendMessage(chatRoomID: self.chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush)
                    
                    outgoingMessage?.messageDictionary[kMESSAGEID] = messageId
                    
                    self.insertNewMessages(messageDictionary: outgoingMessage!.messageDictionary)
                    completion(true)
                    
                }
            }
            return
        }
        
        
        //send audio
        
        if let audioPath = audio {
            
            uploadAudio(autioPath: audioPath, chatRoomId: chatRoomId, view: (self.navigationController?.view)!) { (audioLink) in
                
                if audioLink != nil {
                    
                    let ecryptedText = Encryption.encryptText(chatRoomId: self.chatRoomId, message: "[\(kAUDIO)]")
                    
                    
                    outgoingMessage = OutgoingMessage(message: ecryptedText, audio: audioLink!, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kAUDIO)
                    
                    //JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    //self.finishSendingMessage()
                    
                    messageId = outgoingMessage!.sendMessage(chatRoomID: self.chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush)
                    
                    completion(true)
                }
            }
            return
        }
        
        //send location message
        if location != nil {
            
            let lat: NSNumber = NSNumber(value: 56.35345345)
            let long: NSNumber = NSNumber(value: 26.2342342)
            
            let ecryptedText = Encryption.encryptText(chatRoomId: chatRoomId, message: "[\(kLOCATION)]")
            
            outgoingMessage = OutgoingMessage(message: ecryptedText, latitude: lat, longitude: long, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kLOCATION)
            
            completion(true)
        }
        
        
        messageId = outgoingMessage!.sendMessage(chatRoomID: chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: memberIds, membersToPush: membersToPush)
        
        
        
        DispatchQueue.main.async {
            self.messageInputBar.sendButton.stopAnimating()
        }
        
    }
    
    
    func requiredInitialScrollViewBottomInset() -> CGFloat {
        guard let inputAccessoryView = inputAccessoryView else { return 0 }
        return max(0, inputAccessoryView.frame.height + additionalBottomInset - automaticallyAddedBottomInset)
    }
    
    /// iOS 11's UIScrollView can automatically add safe area insets to its contentInset,
    /// which needs to be accounted for when setting the contentInset based on screen coordinates.
    ///
    /// - Returns: The distance automatically added to contentInset.bottom, if any.
    var automaticallyAddedBottomInset: CGFloat {
        if #available(iOS 11.0, *) {
            var val:CGFloat = messagesCollectionView.adjustedContentInset.bottom - messagesCollectionView.contentInset.bottom
            print("val \(val)")
            
            return val
        } else {
            return 0
        }
    }
    
    //MARK: Configure Methods
    
    
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = false // default false
        
        self.messagesCollectionView.refreshControl =  refreshControl
        //refreshControl.attributedTitle = NSAttributedString(string: "Load earlier messages")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)
            layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
            
        }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ChatViewController.rightSwiped))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.messagesCollectionView.addGestureRecognizer(swipeRight)
        self.messagesCollectionView.frame = self.view.bounds
        
        
    }
    
    
    @objc func rightSwiped() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func setupTitleView(){
        
        let logoImage = UIImage.init(named: "user (1)")
        
        let logoImageView = UIImageView.init(image: logoImage)
        logoImageView.kf.setImage(with: URL(string: withUsers[0].avatar))
        
        logoImageView.frame = CGRect(x:0.0,y:0.0, width:34,height:34.0)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.makeRounded()
        let tapLogo = UITapGestureRecognizer(target: self, action: #selector(self.logoImageTapped(sender:)))
        logoImageView.addGestureRecognizer(tapLogo)
        
        let imageItem = UIBarButtonItem.init(customView: logoImageView)
        let widthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 34)
        let heightConstraint = logoImageView.heightAnchor.constraint(equalToConstant: 34)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        
        //backBarButtonItem = UIImage(named: "back")
        let backImage = UIImage.init(named: "Back")
        let backImageView = UIImageView.init(image: backImage)
        backImageView.frame = CGRect(x:0.0,y:0.0, width:20,height:20.0)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.backButtonTapped(sender:)))
        backImageView.addGestureRecognizer(tap)
        
        let backItem = UIBarButtonItem.init(customView: backImageView)
        navigationItem.leftBarButtonItems =  [backItem,imageItem]
    }
    
    func updateTitleView(title: String, subtitle: String?, baseColor: UIColor = .white) {
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = baseColor
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.textColor = baseColor.withAlphaComponent(0.95)
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.textAlignment = .center
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        if subtitle != nil {
            titleView.addSubview(subtitleLabel)
        } else {
            titleLabel.frame = titleView.frame
        }
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        titleView.isUserInteractionEnabled =  true
        
        let tapLogo = UITapGestureRecognizer(target: self, action: #selector(self.TitleTapped(sender:)))
        titleView.addGestureRecognizer(tapLogo)
        
        navigationItem.titleView = titleView
        
    }
    
    func configureMessageInputBar() {
        
        messageInputBar.delegate = self
        messageInputBar.maxTextViewHeight = 80
        messageInputBar.tintColor = .blue
        messageInputBar.inputTextView.isImagePasteEnabled = false
        let button = InputBarButtonItem()
        button.onKeyboardSwipeGesture { item, gesture in
            if gesture.direction == .left {
                item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 0, animated: true)
            } else if gesture.direction == .right {
                item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 36, animated: true)
            }
        }
        button.setSize(CGSize(width: 36, height: 36), animated: false)
        button.setImage(#imageLiteral(resourceName: "ic_plus").withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        
        button.onSelected {_ in
            self.ShowAttachmentAlertActions()
        }
        
        self.messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        self.messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        self.messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        self.messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        self.messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        self.messageInputBar.inputTextView.layer.borderWidth = 1.0
        self.messageInputBar.inputTextView.layer.cornerRadius = 16.0
        self.messageInputBar.inputTextView.layer.masksToBounds = true
        //self.messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        self.messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        self.messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        
        self.messageInputBar.isTranslucent = false
        
        
        
    }
     func didMoveToWindow() {
        print("winodw moved")
    }
    
    
    func ShowAttachmentAlertActions() {
        
        let alert:UIAlertController=UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            
            let imagePicker = UIImagePickerController()
            
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
                
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.present(imagePicker, animated: true, completion: nil)
            }
            else {
                
                self.DisplayMessage(userMessage: "You don't have camera", title: "Info")
            }
            
        }
        let photoAction = UIAlertAction(title: "Photo", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = ["public.image"]
            (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.present(imagePicker, animated: true, completion: nil)
            
        }
        let videoAction = UIAlertAction(title: "Video", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = ["public.movie"]
            (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.present(imagePicker, animated: true, completion: nil)
            
        }
        
        let imageCamera = UIImage(named: "ic_camera")
        if let image = imageCamera?.imageWithSize(scaledToSize: CGSize(width: 30, height: 30)) {
            cameraAction.setValue(image, forKey: "image")
            cameraAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        }
        alert.addAction(cameraAction)
        
        let imagePhoto = UIImage(named: "ic_library")
        if let image = imagePhoto?.imageWithSize(scaledToSize: CGSize(width: 30, height: 30)) {
            photoAction.setValue(image, forKey: "image")
            photoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        }
        
        alert.addAction(photoAction)
        
        let imageVideo = UIImage(named: "ic_video")
        if let image = imageVideo?.imageWithSize(scaledToSize: CGSize(width: 30, height: 30)) {
            videoAction.setValue(image, forKey: "image")
            videoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        }
        
        alert.addAction(videoAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
        }.onSelected {
            $0.tintColor = UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
        }.onDeselected {
            $0.tintColor = UIColor.lightGray
        }.onTouchUpInside { _ in
            print("Item Tapped")
        }
    }
    // MARK: - Message Data Source
    
    func currentSender() -> SenderType {
        
        return user
        
    }
    
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        if action == NSSelectorFromString("delete:") {
            return true
        } else {
            return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
        if action == NSSelectorFromString("delete:") {
            
            self.messages.remove(at: indexPath.section)
            
            collectionView.deleteSections([indexPath.section])
            
        } else {
            super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
    
    
    //MARK: Message Collection View
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError("MessageKitError.notMessagesCollectionView")
        }
        
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("MessageKitError.nilMessagesDataSource")
        }
        
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return messagesDataSource.typingIndicator(at: indexPath, in: messagesCollectionView)
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        switch message.kind {
        case .text, .attributedText, .emoji:
            let cell = messagesCollectionView.dequeueReusableCell(TextMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            cell.messageBottomLabel.textInsets = UIEdgeInsets(top: 0,left: 10,bottom: 0,right: 0)
            return cell
        case .photo, .video:
            let cell = messagesCollectionView.dequeueReusableCell(MediaMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            
            cell.messageBottomLabel.textInsets = UIEdgeInsets(top: 0,left: 10,bottom: 0,right: 0)
            return cell
        case .location:
            let cell = messagesCollectionView.dequeueReusableCell(LocationMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .audio:
            let cell = messagesCollectionView.dequeueReusableCell(AudioMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .contact:
            let cell = messagesCollectionView.dequeueReusableCell(ContactMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .custom:
            return messagesDataSource.customCell(for: message, at: indexPath, in: messagesCollectionView)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let messagesFlowLayout = collectionViewLayout as? MessagesCollectionViewFlowLayout else { return .zero }
        var size = messagesFlowLayout.sizeForItem(at: indexPath)
        
        //        let msg = self.loadedMessages[indexPath.section]
        //
        //        if msg[kTYPE] as! String == kPICTURE  {
        //
        //            let msgstr = Encryption.decryptText(chatRoomId: chatRoomId, encryptedMessage: msg[kMESSAGE] as! String)
        //
        //            if msgstr != "[picture]" {
        //                size.height = (msgstr.height(constraintedWidth: size.width)) + size.height
        //            }
        //            else {
        //                size.height = size.height + 20
        //            }
        //        }
        //
        return size
    }
    
        
    //MARK: Message Display Delegate
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let msg = self.messages[indexPath.section]
        
        switch message.kind {
        case .photo:
            imageView.kf.indicatorType = .activity
            guard
                let message = message as? MessageKitMessage,
                let url = URL(string: message.url!)
                else {
                    print("Could not convert message into a readable Message format")
                    return
            }
            
            imageView.sd_setImage(with: url) { (image, error, SDImageCacheType, URL) in
                
                if error != nil {
                    self.messages[indexPath.section].photoImage = UIImage(named: "blank")
                }
                else {
                    self.messages[indexPath.section].photoImage = image
                }
            }
        case .video(_):
            imageView.setImage(msg.photoImage!)
        default:
            print("default")
        }
        
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        
        return .bubbleTail(tail, .curved)
        
    }
    func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
        let header = messagesCollectionView.dequeueReusableHeaderView(HeaderReusableView.self, for: indexPath)
        
        let message = messageForItem(at: indexPath, in: messagesCollectionView)
        
        if (indexPath.section == 0) {
            
            header.setup(with: dayElapsed(date: message.sentDate))
            return header
        }
        else {
            if(messages.count > 1) {
                
                print(self.loadedMessages[indexPath.section-1][kMESSAGE])
                let NextMessageDate = messages[indexPath.section - 1].sentDate
                let result  = Calendar.current.compare(NextMessageDate, to: message.sentDate, toGranularity: .day)
                
                switch result {
                case .orderedDescending:
                    print("")
                case .orderedAscending:
                    header.setup(with: dayElapsed(date: message.sentDate))
                    return header
                case .orderedSame:
                    print("")
                }
            }
        }
        return header
    }
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        if section == 0 {
            return CGSize(width: messagesCollectionView.bounds.width, height: HeaderReusableView.height)
        }
        else {
            let message = messages[section]
            if(messages.count > 1) {
                
                let NextMessageDate = messages[section - 1].sentDate
                let result  = Calendar.current.compare(NextMessageDate, to: message.sentDate, toGranularity: .day)
                
                switch result {
                case .orderedAscending:
                    return CGSize(width: messagesCollectionView.bounds.width, height: HeaderReusableView.height)
                default:
                    print("")
                }
            }
        }
        return .zero
    }
    
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        
        // if indexPath.section + 1 == self.loadedMessages.count {
        let status = self.loadedMessages[indexPath.section][kSTATUS] as! String
        let time = self.loadedMessages[indexPath.section][kDATE] as? String
        
        var date: Date!
        
        if let created = time {
            if (created as String).count != 14 {
                
                date = Date()
                
            } else {
                
                date = dateFormatter().date(from: created as String)
                print("after formating\(String(describing: date))")
                
            }
        } else {
            date = Date()
        }
        
        
        let marks = status == "read" ? "✓✓": "✓"
        
        let dateime =  getTimeFromDate(date: date) + " "
        let font = UIFont.systemFont(ofSize: 10)
        let attributes = [NSAttributedString.Key.font: font]
        let adatetime = NSAttributedString(string: dateime, attributes: attributes)
        
        
        if  isFromCurrentSender(message: message) {
            
            return adatetime + NSAttributedString(string: marks, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)])
        }
        else {
            return adatetime
        }
    }
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 15
    }
}
func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString
{
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
}


// MARK: - MessageCellDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatViewController: MessageCellDelegate {
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avtar Tapped")
    }
    
   //---------------------------------------------------------------------------------------------------------------------------------------------
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image Tapped")
        if let indexPath = messagesCollectionView.indexPath(for: cell)
        {
            let msg = self.messages[indexPath.section]
            switch msg.kind {
                
            case .photo:
                var img : UIImage?
                if let image = msg.photoImage {
                    img = image
                }
                else {
                    img = UIImage(named: "blank")
                }
                let imageInfo = GSImageInfo(image: img!, imageMode: .aspectFit, imageHD: nil)
                let transitionInfo = GSTransitionInfo(fromView: self.view)
                let imageViewer    = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                present(imageViewer, animated: true, completion: nil)
                
            case .video:
                
                let url = msg.url
                
                let videoURL = URL(string: url!)
                let player = AVPlayer(url: videoURL!)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
                
                default :
                print("text")
            }
        
        }
    } //---------------------------------------------------------------------------------------------------------------------------------------------
    func didTapMessage(in cell: MessageCollectionViewCell) {
        
        print("Message Tapped")
        if let indexPath = messagesCollectionView.indexPath(for: cell)
        {
            let msg = self.messages[indexPath.section]
            switch msg.kind {
                
            case .video:
                print("video")
                let videoURL = URL(string: (msg.url!))
                let player = AVPlayer(url: videoURL!)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            case .photo:
                var img : UIImage?
                if let image = msg.photoImage {
                    img = image
                }
                else {
                    img = UIImage(named: "blank")
                }
                let imageInfo = GSImageInfo(image: img!, imageMode: .aspectFit, imageHD: nil)
                let transitionInfo = GSTransitionInfo(fromView: self.view)
                let imageViewer    = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                present(imageViewer, animated: true, completion: nil)
            default :
                print("text")
            }
            
            
        }
        
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func didTapPlayButton(in cell: AudioMessageCell) {
        
        print("Audio button Tapped")
        
        //        if let indexPath = messagesCollectionView.indexPath(for: cell) {
        //            let mkmessage = mkmessageAt(indexPath)
        //            if (mkmessage.mediaStatus == MEDIASTATUS_SUCCEED) {
        //                audioController.toggleSound(for: mkmessage, in: cell)
        //            }
        //        }
    }
    //MARK: Message Bubble Settings
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        let outgoingColor = UIColor(red: 66/255, green: 192/255, blue: 194/255,alpha: 1.0)
        
        let incommingColor = UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)
        
        return isFromCurrentSender(message: message) ? outgoingColor : incommingColor
    }
    
    func getFCMTokensByExternalChatIds(ids: String){
        
        let url = URL(string:"\(HelperFuntions.GetFCMTokensByExternalChatIds)?ids=\(ids)")
        
        let MyHeader = ["content-type": "application/json"]
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
            
            
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
                    self.memberstoFCMPush = []
                    if let dict = responseJSON.result.value as? NSDictionary {
                        
                        if let json = JSON(dict.object(forKey: "fcmToken") as Any).array {
                            for a in json {
                                let token = a.description as? String
                                if  token != nil {
                                    self.memberstoFCMPush.append(token!)
                                }
                            }
                        }
                        
                        
                    }
                }
                
                
                
            case .failure(let error):
                print(error)
                
            }
            
        }
        
    }
    
}



