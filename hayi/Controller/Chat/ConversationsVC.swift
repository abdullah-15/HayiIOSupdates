//
//  ConversationsVC.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 17/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ConversationsVC: UIViewController,UITableViewDelegate,UITableViewDataSource,ConversationListCellDelegate {
    
    deinit {
            NotificationCenter.default.removeObserver(self)
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var noMessageView: UITableView!
    
    func didTapAvatarImage(indexPath: IndexPath) {
        print("User Tapped")
    
        let chatvc = ChatViewController()
        chatvc.hidesBottomBarWhenPushed =  true
        navigationController?.pushViewController(chatvc, animated: true)
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var recentChats: [NSDictionary] = []
    var filtered: [NSDictionary] = []
    
    var recentListener: ListenerRegistration!
    var _isGoingToChatRoom = false
    var _roomID = ""
    
    override func viewWillAppear(_ animated: Bool) {
        let obj = self.tabBarController?.tabBar.items?[2]
        if let item = obj {
            item.badgeValue = nil
        }
        loadRecentChats()
        tableView.tableFooterView = UIView()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(notificatonArrived(_:)), name: NSNotification.Name(rawValue: "newnotification"), object: nil)
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        //self.title = "Messages"
        self.navigationItem.title = "Messages"
//        loadRecentChats()
    }
    
    //MARK: TabeViewDataSource 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(recentChats.count)
    
        return recentChats.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellConversation",for: indexPath) as! ConversationListCell
        
        let recent = recentChats[indexPath.row]
            
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        
        cell.delegate = self
        
        //print("Recent Chats Cell")
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var recent: NSDictionary!
        
        recent = recentChats[indexPath.row]
//
//        if searchController.isActive && searchController.searchBar.text != "" {
//            recent = filteredChats[indexPath.row]
//        } else {
//            recent = recentChats[indexPath.row]
//        }

        restartRecentChat(recent: recent)
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
        if let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as?   ChatViewController
            
        {
            chatVC.hidesBottomBarWhenPushed = true
            chatVC.titleName = (recent[kWITHUSERFULLNAME] as? String)!
            chatVC.memberIds = (recent[kMEMBERS] as? [String])!
            chatVC.membersToPush = (recent[kMEMBERSTOPUSH] as? [String])!
            chatVC.memberstoFCMPush = (recent[kFCMToken] as? [String])!
            chatVC.chatRoomId = (recent[kCHATROOMID] as? String)!
            
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
//
//        let chatVC = ChatViewController()
//        chatVC.hidesBottomBarWhenPushed = true
//        chatVC.titleName = (recent[kWITHUSERFULLNAME] as? String)!
//        chatVC.memberIds = (recent[kMEMBERS] as? [String])!
//        chatVC.membersToPush = (recent[kMEMBERSTOPUSH] as? [String])!
//        chatVC.memberstoFCMPush = (recent[kFCMToken] as? [String])!
//        chatVC.chatRoomId = (recent[kCHATROOMID] as? String)!
        //chatVC.isGroup = (recent[kTYPE] as! String) == kGROUP
        
        //navigationController?.pushViewController(chatVC, animated: true)
    }
    
    //MARK: Load Recent Chats
    
    func loadRecentChats()  {
        
        print("load Recent")
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else {
                
                print("no snapshot")
                return
            }
            self.recentChats = []
            if !snapshot.isEmpty {
                
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                
                for recent in sorted {
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                        
                        self.recentChats.append(recent)
                        
                    }
                }
                
                self.checkBadge()
                self.tableView.reloadData()
                if self._isGoingToChatRoom {
                    self.gotoChatController()
                }
            }
            DispatchQueue.main.async {
                if self.recentChats.count == 0 {
                
                    self.noMessageView.isHidden = false
                    self.tableView.isHidden = true
                }
                else {
                    self.noMessageView.isHidden = true
                    self.tableView.isHidden = false
                }
            }
        })
    }
    
    private func checkBadge() {
        for recentChat in self.recentChats {
            if let counter = recentChat[kCOUNTER] as? Int {
                if counter != 0 {
                    appDelegate.addBadgeOnChatIcon()
                    break
                }else {
                    UserDefaults.standard.set(false, forKey: KeyBadge)
                }
            }
        }
    }
}


// MARK: - Go To Chat Room Work when push notification received
private extension ConversationsVC {
    private func gotoChatController() {
        _isGoingToChatRoom = false
        
        for recent in recentChats {
            if (recent[kCHATROOMID] as? String)! == _roomID {
                _roomID = ""
                pushToChatController(recent: recent)
                break
            }
        }
    }
    
    private func pushToChatController(recent: NSDictionary) {
        restartRecentChat(recent: recent)
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
        if let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
            chatVC.hidesBottomBarWhenPushed = true
            chatVC.titleName = (recent[kWITHUSERFULLNAME] as? String)!
            chatVC.memberIds = (recent[kMEMBERS] as? [String])!
            chatVC.membersToPush = (recent[kMEMBERSTOPUSH] as? [String])!
            chatVC.memberstoFCMPush = (recent[kFCMToken] as? [String])!
            chatVC.chatRoomId = (recent[kCHATROOMID] as? String)!
            
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}


