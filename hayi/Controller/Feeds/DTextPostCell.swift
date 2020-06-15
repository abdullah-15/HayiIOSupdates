//
//  DescriptionTableViewCell.swift
//  Assignment
//
//  Created by Adees Farakh on 30.10.19.
//  Copyright © 2019 AdiAtizaz. All rights reserved.
//

import UIKit
import Kingfisher
import ActiveLabel


class DTextPostCell: UITableViewCell {
    
    
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    @IBOutlet weak var postByAvatar: UIImageView!
    @IBOutlet weak var postByName: UILabel!
    @IBOutlet weak var postCreatedTime: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var postActionButton: UIButton!
    
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet var lblDescription: ActiveLabel!
    
    var delegate : PostActionsDelegate!
    var delegateView : FeedsViewImageDelegate!
    var delegateprofileView: ProfileViewDelegate!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        postByAvatar.layer.borderWidth = 1
        postByAvatar.layer.masksToBounds = false
        postByAvatar.layer.borderWidth = 0
        postByAvatar.layer.cornerRadius = postByAvatar.frame.height/2
        postByAvatar.clipsToBounds = true
        lblDescription.URLColor = UIColor(hexString: "#1893c4")
        lblDescription.isUserInteractionEnabled = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func assignTags(indexPath:IndexPath){
        
        likeButton.tag = indexPath.row
        commentButton.tag = indexPath.row
        postByName.tag = indexPath.row
        
        likeButton.addTarget(self, action: #selector(didPressedLikeButton(sender:)), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didPressedCommentButton(sender:)), for: .touchUpInside)
        
        let tapAvatar = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(tapGestureRecognizer:)))
        
         postByAvatar.isUserInteractionEnabled = true
         postByAvatar.addGestureRecognizer(tapAvatar)
    
        let tapProfile = UITapGestureRecognizer(target: self, action: #selector(profileNameTapped(tapGestureRecognizer:)))
        postByName.isUserInteractionEnabled = true
         postByName.addGestureRecognizer(tapProfile)
        
    }
    @objc func avatarTapped(tapGestureRecognizer: UITapGestureRecognizer)
          {
            
              self.delegateView.didSelectViewImage(image: postByAvatar.image!)
          }
    @objc func profileNameTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.delegateprofileView.didSelectProfileName(tag: postByName.tag)
    }
    @objc func didPressedLikeButton(sender:UIButton){
        
        delegate.LikeButtonPressed(tag: sender.tag)
    }
    @objc func didPressedCommentButton(sender:UIButton){
        
        delegate.CommentButtonPressed(tag: sender.tag)
    }
    
    func populateData(post:post) {
        
        
        lblDescription.text = post.postMessage
        
        if post.CreatedByUser.profileImage != nil {
            
            let url = post.CreatedByUser.profileImage!.replacingOccurrences(of: " ", with: "%20")
            
            self.postByAvatar.kf.indicatorType = .activity
            self.postByAvatar.kf.setImage(with: URL(string:url))
        }
        
        self.postByName.text = post.CreatedByUser.fullName
        
        
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
    
    @IBAction func postActionButtonPressed(_ sender: UIButton) {
        self.delegate.DidSelectReportPost(tag: sender.tag)
    }
}
