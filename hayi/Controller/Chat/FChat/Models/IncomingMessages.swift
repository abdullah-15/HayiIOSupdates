//
//  IncomingMessages.swift
//  iChat
//
//  Created by David Kababyan on 17/06/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import Foundation
import MessageKit
import SDWebImage


class IncomingMessage {
    
//
//    var collectionView: JSQMessagesCollectionView
//
//
//    init(collectionView_: JSQMessagesCollectionView) {
//        collectionView = collectionView_
//    }
    
    
    //MARK: CreateMessage
    
    func createMessage(messageDictionary: NSDictionary, chatRoomId: String) -> MessageKitMessage? {
        
        var message: MessageKitMessage?
        
        let type = messageDictionary[kTYPE] as! String
        
        switch type {
        case kTEXT:
            message = createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kPICTURE:
            message = createPictureMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kVIDEO:
          message = createVideoMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
//        case kAUDIO:
//            message = createAudioMessage(messageDictionary: messageDictionary)
//        case kLOCATION:
//            message = createLocationMessage(messageDictionary: messageDictionary)
        default:
            print("Unknown message type")
        }
        
        
        if message != nil {
           return message
        }
        
        return nil
    }

    
    //MARK: Create Message types
    
    func createTextMessage(messageDictionary: NSDictionary, chatRoomId: String) -> MessageKitMessage {
        
        let name = messageDictionary[kSENDERNAME] as! String
        let userId = messageDictionary[kSENDERID] as! String
        let messageId = messageDictionary[kMESSAGEID] as! String
        
        let messageKitUser = MessageKitUser(senderId: userId, displayName: name)
        
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            date = Date()
        }
        let decryptedText = Encryption.decryptText(chatRoomId: chatRoomId, encryptedMessage: messageDictionary[kMESSAGE] as! String)
        let msg =  MessageKitMessage(text: decryptedText, user: messageKitUser, messageId: messageId, date: date)
        
        return msg
    }
    
    func createPictureMessage(messageDictionary: NSDictionary, chatRoomId: String) -> MessageKitMessage {
         
        let name = messageDictionary[kSENDERNAME] as! String
             let userId = messageDictionary[kSENDERID] as! String
             let messageId = messageDictionary[kMESSAGEID] as! String
        
    let messageKitUser = MessageKitUser(senderId: userId, displayName: name)

         var date: Date!
         
         if let created = messageDictionary[kDATE] {
             if (created as! String).count != 14 {
                 date = Date()
             } else {
                 date = dateFormatter().date(from: created as! String)
             }
         } else {
             date = Date()
         }
        
        let path = messageDictionary[kPICTURE] as! String
        
        let msg = MessageKitMessage(image: UIImage(named: "blank")!, user: messageKitUser, messageId: messageId, date: date,url: path)
  
         return msg
     }
    
      func createVideoMessage(messageDictionary: NSDictionary, chatRoomId: String) -> MessageKitMessage {
           
          let name = messageDictionary[kSENDERNAME] as! String
               let userId = messageDictionary[kSENDERID] as! String
               let messageId = messageDictionary[kMESSAGEID] as! String
          
      let messageKitUser = MessageKitUser(senderId: userId, displayName: name)

           var date: Date!
           
           if let created = messageDictionary[kDATE] {
               if (created as! String).count != 14 {
                   date = Date()
               } else {
                   date = dateFormatter().date(from: created as! String)
               }
           } else {
               date = Date()
           }
        
            var image: UIImage?
        
            let pictureData =  messageDictionary[kPICTURE] as! String
        
            let decodedData = NSData(base64Encoded: pictureData, options: NSData.Base64DecodingOptions(rawValue: 0))
        
            image = UIImage(data: decodedData! as Data)
        
          let path = messageDictionary[kVIDEO] as! String
        
          var msg = MessageKitMessage(thumbnail: image!, user: messageKitUser, messageId: messageId, date: date,url: path)
            msg.photoImage = image!
    
           return msg
       }
    


    
    //MARK: Helper
    
    func returnOutgoingStatusForUser(senderId: String) -> Bool {
    
        return senderId == FUser.currentId()
    }


}
