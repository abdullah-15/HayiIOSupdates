//
//  HomeTableViewCell.swift
//  Assignment
//
//  Created by Adees Farakh on 18.09.19.
//  Copyright © 2019 AdiAtizaz. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher
import ActiveLabel

protocol FeedsViewCellDelegate {
    func didSelectPlayVideo(tag:Int)
}
class VideoPostCell: UITableViewCell {
    

    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    @IBOutlet weak var postByAvatar: UIImageView!
    @IBOutlet weak var postByName: UILabel!
    @IBOutlet weak var postCreatedTime: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var postActionButton: UIButton!
    
    @IBOutlet weak var commentButton: UIButton!
    
    
    
    var delegateFeeds : FeedsViewCellDelegate!
    var delegateActions : PostActionsDelegate!
    
    var delegateView : FeedsViewImageDelegate!
    var delegateprofileView: ProfileViewDelegate!
    
    @IBOutlet var btnPlayVideo: UIButton!
    
    
    @IBOutlet var lblDescription: ActiveLabel!
    @IBOutlet var imgNews: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        postByAvatar.layer.borderWidth = 1
        postByAvatar.layer.masksToBounds = false
        postByAvatar.layer.borderWidth = 0
        postByAvatar.layer.cornerRadius = postByAvatar.frame.height/2
        postByAvatar.clipsToBounds = true
        lblDescription.URLColor = UIColor(hexString: "#1893c4")
        
        self.imgNews.contentMode = .scaleAspectFill
    }
    
    func assignTags(indexPath:IndexPath){
        
        likeButton.tag = indexPath.row
        commentButton.tag = indexPath.row
        btnPlayVideo.tag = indexPath.row
        postByName.tag = indexPath.row
        
        likeButton.addTarget(self, action: #selector(didPressedLikeButton(sender:)), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didPressedCommentButton(sender:)), for: .touchUpInside)
        btnPlayVideo.addTarget(self, action: #selector(didSelectPlayVideo(sender:)), for: .touchUpInside)

      let tapAvatar = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(tapGestureRecognizer:)))
      
           postByAvatar.isUserInteractionEnabled = true
           postByAvatar.addGestureRecognizer(tapAvatar)
        
        let tapProfile = UITapGestureRecognizer(target: self, action: #selector(profileNameTapped(tapGestureRecognizer:)))
        postByName.isUserInteractionEnabled = true
        postByName.addGestureRecognizer(tapProfile)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        self.delegateView.didSelectViewImage(image: tappedImage.image!)
    }
    @objc func avatarTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.delegateView.didSelectViewImage(image: postByAvatar.image!)
    }
    @objc func profileNameTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.delegateprofileView.didSelectProfileName(tag: postByName.tag)
    }
    
    @objc func didSelectPlayVideo(sender:UIButton){
        
        delegateFeeds.didSelectPlayVideo(tag: sender.tag)
    }
    
    @objc func didPressedLikeButton(sender:UIButton){
        
        delegateActions.LikeButtonPressed(tag: sender.tag)
    }
    @objc func didPressedCommentButton(sender:UIButton){
        
        delegateActions.CommentButtonPressed(tag: sender.tag)
    }
    
    func populateData(post:post){
        
        lblDescription.text = post.postMessage
        
        self.imgNews.kf.indicatorType = .activity
        
        let urlString = post.content?[0].path?.replacingOccurrences(of: " ", with: "%20")
        
        let url:URL? = URL(string: urlString!)
        
        DispatchQueue.global().async {
            
            if let uri = url {
                
                let image = self.generateThumbnail(path: uri)
                
                DispatchQueue.main.async {
                    
                    self.imgNews.image = image
                }
            }
        }
        
        
        if post.CreatedByUser.profileImage != nil {
            
            let url = post.CreatedByUser.profileImage!.replacingOccurrences(of: " ", with: "%20")
            
            self.postByAvatar.kf.indicatorType = .activity
            self.postByAvatar.kf.setImage(with: URL(string:url))
        }
        
        self.postByName.text = post.CreatedByUser.fullName
        
        
        self.likeCountLabel.isHidden = false
        
        
       
        let actualcount = post.likeCount ?? 0
             if actualcount != 0 {
                 self.likeCountLabel.text = "\(actualcount)"
             }
             else {
                 self.likeCountLabel.text = ""
             }
             
             
             if post.selfLiked == 1 {
                 
                 let image = UIImage(named: "like-self-liked")!.withRenderingMode(.alwaysTemplate)
                 self.likeButton.setImage(image, for: UIControl.State.normal)
                 self.likeButton.tintColor = UIColor(hexString: "#42C0C4")
                 //self.likeButton.setTitleColor(UIColor(hexString: "#42C0C4"), for: UIControl.State.normal)
                 //self.likeButton.setTitle("Liked", for: UIControl.State.normal)
             }
             else {
                 
                 let image = UIImage(named: "like-button")!.withRenderingMode(.alwaysTemplate)
                 self.likeButton.setImage(image, for: UIControl.State.normal)
                 self.likeButton.tintColor = UIColor.black
        
             }
             
        
        let actualcountComments = post.commentCount ?? 0
        
        if actualcountComments != 0 {
            self.commentCountLabel.text = "\(actualcountComments)"
        }
        else {
            
            self.commentCountLabel.text = ""
        }
        
        
        
        
        let dateFormatterGet =  dateFormatter2()
        
        let truncatedDate =  post.created!.components(separatedBy: ".")[0]
        
        let date: Date? = dateFormatterGet.date(from: truncatedDate)
        
        self.postCreatedTime.text = dayElapsedData3(date: date!)
        
        
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
    @IBAction func postActionButtonPressed(_ sender: UIButton) {
          self.delegateActions.DidSelectReportPost(tag: sender.tag)
      }
    
    
}
