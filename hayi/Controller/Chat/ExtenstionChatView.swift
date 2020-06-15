//
//  ExtenstionChatView.swift
//  hayi-ios2
//
//  Created by MacBook Pro on 26/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import PKHUD

extension ChatViewController: UITextViewDelegate{
    
    
    func removeListeners() {
        
        if typingListener != nil {
            typingListener!.remove()
        }
        if newChatListener != nil {
            newChatListener!.remove()
        }
        if updatedChatListener != nil {
            updatedChatListener!.remove()
        }
        if UserStatusListener != nil {
            UserStatusListener!.remove()
        }
    }
    
    //MARK: LoadMessages
    
    func loadMessages() {
        HUD.show(.rotatingImage(UIImage(named: "progress")))
        //to update message status
        updatedChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoomId).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                snapshot.documentChanges.forEach({ (diff) in
                    
                    if diff.type == .modified {
                        self.updateMessage(messageDictionary: diff.document.data() as NSDictionary)
                    }
                })
            }
        })
        
        // get last 200 messages
        reference(.Message).document(FUser.currentId()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: 30).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {
                self.initialLoadComplete = true
                self.listenForNewChats()
                return
            }
            
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            
            //remove bad messages
            self.loadedMessages = self.removeBadMessages(allMessages: sorted)
            
            
            //add dummy message
            self.initialLoadComplete = true
            //self.addDummyMessages()
            self.insertMessages()
            
            
            //    self.finishReceivingMessage(animated: true)
            
            self.initialLoadComplete = true
            self.fectchingMore = false
            
            //self.getPictureMessages()
            
            //    self.getOldMessagesInBackground()
            self.listenForNewChats()
        }
        
    }
    
    func listenForNewChats() {
        
        var lastMessageDate = "0"
        
        if loadedMessages.count > 0 {
            lastMessageDate = loadedMessages.last![kDATE] as! String
        }
        
        
        newChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                for diff in snapshot.documentChanges {
                    
                    if (diff.type == .added) {
                        
                        let item = diff.document.data() as NSDictionary
                        
                        if let type = item[kTYPE] {
                            
                            if self.legitTypes.contains(type as! String) {
                                
                                //this is for picture messages
                                if type as! String == kPICTURE {
                                    //self.addNewPictureMessageLink(link: item[kPICTURE] as! String)
                                }
                                
                               self.insertNewMessages(messageDictionary: item)
                                
                            }
                        }
                    }
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: true)

                }
                
            }
            
        })
    }
    
    func getOldMessagesInBackground() {
        
        if loadedMessages.count > 10 {
            
            let firstMessageDate = loadedMessages.first![kDATE] as! String
            
            reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isLessThan: firstMessageDate).getDocuments { (snapshot, error) in
                
                guard let snapshot = snapshot else { return }
                
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
                
                
                self.advanceLoadedMessages = self.removeBadMessages(allMessages: sorted) + self.loadedMessages
                
                //self.getPictureMessages()
                
                
                self.maxMessageNumber = self.loadedMessages.count - self.loadedMessagesCount - 1
                self.minMessageNumber = self.maxMessageNumber - kNUMBEROFMESSAGES
            }
        }
    }
    
    @objc func refresh(_ sender:AnyObject) {
        
        var date:String = ""
        if self.loadedMessages.count >= 1 {
            
            date = self.loadedMessages[0][kDATE] as! String
        }
        else
        {
            date = dateFormatter().string(from: Date())
        }
        
        reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isLessThan: date).limit(to: 100).order(by: kDATE, descending: true).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {
                
                return
            }
            
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            
            //remove bad messages
            let oldMessages =  self.removeBadMessages(allMessages: sorted)
            
            DispatchQueue.main.async {
                
                if oldMessages.count > 0 {
                    
                    self.insertEarlierMessagesReverse(messagesDictionary: oldMessages)
                }
                self.refreshControl.endRefreshing()
                
                
            }
        }
        
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
     //   self.view.layoutIfNeeded()
    }
    
    
    //MARK: InsertMessages
    
    func insertMessages() {
        
        maxMessageNumber = loadedMessages.count
        minMessageNumber = 0
        
        for i in minMessageNumber ..< maxMessageNumber {
            let messageDictionary = loadedMessages[i]
            
            insertInitialLoadMessages(messageDictionary: messageDictionary)
            loadedMessagesCount += 1
        }
        print("\(self.loadedMessages.count)")
        DispatchQueue.main.async {
            HUD.hide()
        }
    }

    func insertInitialLoadMessages(messageDictionary: NSDictionary)  {

        
        if (messageDictionary[kSENDERID] as! String) != FUser.currentId() && messageDictionary[kREADDATE] as? String == nil  {
            
            OutgoingMessage.updateMessage(withId: messageDictionary[kMESSAGEID] as! String, chatRoomId: chatRoomId, memberIds: memberIds)
        }
        
        let inMsg = IncomingMessage()
        
        let newMsg = inMsg.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        
        if let newMsg = newMsg {
            
            messages.append(newMsg)
             
            
        }
        
            
          self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom(animated: true)
            
        
       
    
    }
    
    func insertNewMessages(messageDictionary: NSDictionary)  {

        
        if (messageDictionary[kSENDERID] as! String) != FUser.currentId() && messageDictionary[kREADDATE] as? String == nil  {
            
            OutgoingMessage.updateMessage(withId: messageDictionary[kMESSAGEID] as! String, chatRoomId: chatRoomId, memberIds: memberIds)
        }
        
        let inMsg = IncomingMessage()
        
        let newMsg = inMsg.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
    
        if let newMsg = newMsg {
            messages.append(newMsg)
            self.loadedMessages.append(messageDictionary)
           
            
        }
        
          self.messagesCollectionView.reloadData()
            //self.messagesCollectionView.scrollToBottom(animated: false)
        
    }
    
    func isDuplicate(messageId:String)-> Bool {
        
        var isExists = false
        
        for i in 0..<self.messages.count {
            let msg = self.messages[i]
            if msg.messageId == messageId {
                isExists = true
                break
            }
        }
        return isExists
    }
    
    func insertEarlierMessages(messagesDictionary: [NSDictionary]) {
        let prevMessages = self.loadedMessages
        
        loadedMessagesCount = 0
        self.messages = []
        self.loadedMessages = []
        
        for i in 0 ..< messagesDictionary.count - 1  {
            
            let messageDictionary = messagesDictionary[i]
            
            insertLoadedMessages(messageDictionary: messageDictionary)
            
            loadedMessagesCount += 1
        }
        for i in 0 ..< prevMessages.count - 1  {
            
            let messageDictionary = prevMessages[i]
            
            insertLoadedMessages(messageDictionary: messageDictionary)
            
            loadedMessagesCount += 1
        }
        DispatchQueue.main.async {
            
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
        
    }
    
    func insertLoadedMessages(messageDictionary: NSDictionary)  {

        
        if (messageDictionary[kSENDERID] as! String) != FUser.currentId() && messageDictionary[kREADDATE] as? String == nil  {
            
            OutgoingMessage.updateMessage(withId: messageDictionary[kMESSAGEID] as! String, chatRoomId: chatRoomId, memberIds: memberIds)
        }
        
        let inMsg = IncomingMessage()
        
        let newMsg = inMsg.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        
        if let newMsg = newMsg {
            
            messages.append(newMsg)
            self.loadedMessages.append(messageDictionary)

        }
        
    }
    
    func insertEarlierMessagesReverse(messagesDictionary: [NSDictionary]) {
        
        for i in (0 ..< messagesDictionary.count ).reversed()  {
            print("i: \(i) " )
            let messageDictionary = messagesDictionary[i]
            
            insertLoadedMessagesAtStart(messageDictionary: messageDictionary)
            
            loadedMessagesCount += 1
        }
        
        DispatchQueue.main.async {
            let count = self.loadedMessages.count - 30
            if count > 0 {
                self.messagesCollectionView.scrollToItem(at: IndexPath(item: 0, section: count + 1), at: .top, animated: true)
            }
        }
        
    }
    
    func insertLoadedMessagesAtStart(messageDictionary: NSDictionary)  {

        
        if (messageDictionary[kSENDERID] as! String) != FUser.currentId() && messageDictionary[kREADDATE] as? String == nil  {
            
            OutgoingMessage.updateMessage(withId: messageDictionary[kMESSAGEID] as! String, chatRoomId: chatRoomId, memberIds: memberIds)
        }
        
        let inMsg = IncomingMessage()
        
        let newMsg = inMsg.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        
        if let newMsg = newMsg {
            
            
            DispatchQueue.main.async {
                
                self.messages.insert(newMsg, at: 0)
                
                self.loadedMessages.insert(messageDictionary, at: 0)
                self.messagesCollectionView.reloadData()

               // let indexSet = IndexSet.init(integer:0)
//                self.messagesCollectionView.performBatchUpdates({
//                        self.messagesCollectionView.insertSections(indexSet)
                //}, completion: nil)
                
            }
        }
        
    }

    func updateMessage(messageDictionary: NSDictionary) {
        
        for index in 0 ..< loadedMessages.count {
            let temp = loadedMessages[index]
            
            if messageDictionary[kMESSAGEID] as! String == temp[kMESSAGEID] as! String {
                loadedMessages[index] = messageDictionary
            
                var indexPath = IndexPath(row: 0,section: index)
            
                self.messagesCollectionView.reloadItems(at: [indexPath])
                
                
            }
        }
    }
    
    //MARK: LoadMoreMessages
    
    func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        
        if loadOld {
            maxMessageNumber = minNumber - 1
            minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        }
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            
            let messageDictionary = loadedMessages[i]
            insertNewMessage(messageDictionary: messageDictionary)
            loadedMessagesCount += 1
        }
        
        loadOld = true
        //self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
    }
    
    func insertNewMessage(messageDictionary: NSDictionary) {
        
        //let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        //et message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        
      
       // messages.insert(message!, at: 0)
    }
    
    //MARK: User Status
    
    func createUserStatusObserver() {
        if (withUsers.count > 0) {
            print("add listener\(withUsers[0].objectId))")
        UserStatusListener = reference(.User).document(withUsers[0].objectId).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                
                for data in snapshot.data()! {
                    if data.key == "isOnline" {
                        
                        let status = data.value as! Bool
                        print("status\(status)")
                        //self.showTypingIndicator = typing
                        
                        if status {
                          //  self.scrollToBottom(animated: true)
                            if self.withUsers.count >= 1{
                                self.withUsers[0].isOnline = true
                                self.updateTitleView(title: self.withUsers[0].fullname, subtitle: "Online")
                            }
                        }
                        else {
                            
                            if self.withUsers.count >= 1{
                                self.withUsers[0].isOnline = false
                                self.updateTitleView(title: self.withUsers[0].fullname, subtitle: "")
                            }
                        }
                    }
                }
            }
        })
        }
    }
    
    
    //MARK: Typing Indicator
    
    func createTypingObserver() {
        
        typingListener = reference(.Typing).document(chatRoomId).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                
                for data in snapshot.data()! {
                    if data.key != FUser.currentId() {
                        
                        let typing = data.value as! Bool
                        print("Typing")
                        //self.showTypingIndicator = typing
                        
                        if typing {
                          //  self.scrollToBottom(animated: true)
                            if self.withUsers.count >= 1{
                                self.updateTitleView(title: self.withUsers[0].fullname, subtitle: "Typing")
                                
                            }
                            
                        }
                        else {
                            
                            if self.withUsers.count >= 1{
                                
                                if self.withUsers[0].isOnline == true {
                            
                                    self.updateTitleView(title: self.withUsers[0].fullname, subtitle: "Online")
                                }
                                else {
                                    self.updateTitleView(title: self.withUsers[0].fullname, subtitle: "")
                                }
                            }
                        }
                    }
                }
            } else {
                reference(.Typing).document(self.chatRoomId).setData([FUser.currentId() : false])
                
                
            }
            
        })
        
    }
    
    func typingCounterStart() {
        
        typingCounter += 1
        
        typingCounterSave(typing: true)
        
        self.perform(#selector(self.typingCounterStop), with: nil, afterDelay: 2.0)
    }
    
    @objc func typingCounterStop() {
        typingCounter -= 1

        if typingCounter == 0 {
            typingCounterSave(typing: false)
        }
    }

    func typingCounterSave(typing: Bool) {
        
        reference(.Typing).document(chatRoomId).updateData([FUser.currentId() : typing])
    }
 
       
    
    func removeBadMessages(allMessages: [NSDictionary]) -> [NSDictionary] {
           
           var tempMessages = allMessages
           
           for message in tempMessages {
               
               if message[kTYPE] != nil {
                   if !self.legitTypes.contains(message[kTYPE] as! String) {
                       
                       //remove the message
                       tempMessages.remove(at: tempMessages.index(of: message)!)
                   }
               } else {
                   tempMessages.remove(at: tempMessages.index(of: message)!)
               }
           }
           
           return tempMessages
       }
    
    
    @objc func showUserProfile() {
        
               print("show profile VC")
//
//        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileViewTableViewController
//
//        profileVC.user = withUsers.first!
//        self.navigationController?.pushViewController(profileVC, animated: true)
    }
   
    
    //MARK: Push notifications
    
    func sendPushNotification(to token: String, title: String, body: String,profileUrl: String) {
        
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
        "notification" : ["title" : title, "body" : body],
        "data" : ["chat" : true,
                  "chatRoomId": chatRoomId,
                  "otherUserId": FUser.currentUser()!.serverUserId,
                  "otherUserUID": FUser.currentId(),
                  "firstName": FUser.currentUser()!.firstname,
                  "lastName": FUser.currentUser()!.lastname,
                  "profileImage": FUser.currentUser()!.avatar],
        "apns" : ["payload" : [ "aps" : [ "mutable-content": 1] ],
                  "fcm_options": ["image": profileUrl] ] ]
//        let paramString: [String : Any] = ["to" : token,
//                                           "notification" : ["title" : title, "body" : body],
//                                           "data" : ["user" : "test_id"], "apns" : ["payload" : [ "aps" : [ "mutable-content": 1] ], "fcm_options": ["image": profileUrl] ] ]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAA0NJ4lFI:APA91bEc0BXpFjmEBN7xQ072r6grz9oEYD3OqgvYgKeoGglunbxVhpMJLJziTeyYpuMKg56CDBMVM6bsAphlFwLwY4MxLje_y_r3JgMHe2xejRjINa6bwyAFHpnj_CuvuleVI9BCMfNG", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
}
