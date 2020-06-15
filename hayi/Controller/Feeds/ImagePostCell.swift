//
//  PhotoTableViewCell.swift
//  Assignment
//
//  Created by Adees Farakh on 30.10.19.
//  Copyright © 2019 AdiAtizaz. All rights reserved.
//

import UIKit
import Kingfisher
import ImageSlideshow
import ActiveLabel
import Firebase

protocol FeedsViewImageDelegate{
    func didSelectViewImage(image:UIImage)
}
protocol ProfileViewDelegate {
    func didSelectProfileName(tag:Int)
}

class ImagePostCell: UITableViewCell {
    
    
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLebel: UILabel!
    
    @IBOutlet weak var postByAvatar: UIImageView!
    @IBOutlet weak var postByName: UILabel!
    @IBOutlet weak var postCreatedTime: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var postActionButton: UIButton!
    
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var slidesShow: ImageSlideshow!
    
    
    @IBOutlet weak var lblDescription: ActiveLabel!
    
    
    
    var delegateActions : PostActionsDelegate!
    
    var delegateView : FeedsViewImageDelegate!
    
    var delegateprofileView: ProfileViewDelegate!
    
    
    var kingfisherSource:[KingfisherSource] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        postByAvatar.layer.borderWidth = 1
        postByAvatar.layer.masksToBounds = false
        postByAvatar.layer.borderWidth = 0
        postByAvatar.layer.cornerRadius = postByAvatar.frame.height/2
        postByAvatar.clipsToBounds = true
        lblDescription.URLColor = UIColor(hexString: "#1893c4")
        
        self.slidesShow.delegate = self
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
        
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        
        //imgNews.isUserInteractionEnabled = true
        // imgNews.addGestureRecognizer(tapImage)
        
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
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        self.delegateView.didSelectViewImage(image: tappedImage.image!)
    }
    @objc func profileNameTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.delegateprofileView.didSelectProfileName(tag: postByName.tag)
    }
    
    
    @objc func didPressedLikeButton(sender:UIButton){
        
        delegateActions.LikeButtonPressed(tag: sender.tag)
    }
    @objc func didPressedCommentButton(sender:UIButton){
        
        delegateActions.CommentButtonPressed(tag: sender.tag)
    }
    
    
    func populateData(post: post){
        
        
        setUpSlideSource(content: post.content)
        
        setUpSlideShow()
        
        self.lblDescription.text = post.postMessage
        
        
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
            self.commentCountLebel.text = "\(actualcountComments)"
        }
        else {
            self.commentCountLebel.text = ""
        }
        
        let dateFormatterGet =  dateFormatter2()
        
        if let created = post.created {
            let truncatedDate =  post.created!.components(separatedBy: ".")[0]
            let date: Date? = dateFormatterGet.date(from: truncatedDate)
            if let d = date {
                self.postCreatedTime.text = dayElapsedData3(date: d)
            }
            else {
                self.postCreatedTime.text = ""
            }
        }
        else {
            self.postCreatedTime.text = ""
        }
        
    }
    func setUpSlideShow()  {
        slidesShow.slideshowInterval = 3.0
        slidesShow.isUserInteractionEnabled = true
        slidesShow.draggingEnabled = true
        slidesShow.pageIndicatorPosition = .init(horizontal: .center, vertical: .customBottom(padding: 2.5))
        slidesShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        let pageControl = UIPageControl()
        
        pageControl.currentPageIndicatorTintColor = UIColor(hexString: "#42c0c4" , alpha: 0.8)
        pageControl.pageIndicatorTintColor = UIColor.white
        slidesShow.pageIndicator = pageControl
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slidesShow.activityIndicator = DefaultActivityIndicator()
        
        
        slidesShow.setImageInputs(kingfisherSource)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ImagePostCell.didTap))
        slidesShow.addGestureRecognizer(recognizer)
        slidesShow.isUserInteractionEnabled = true
    }
    
    
    @objc func didTap() {
        
        
        let image = slidesShow.currentSlideshowItem?.imageView.image
        if let img = image {
            self.delegateView.didSelectViewImage(image: img)
        }
    }
    
    func setUpSlideSource(content:[postMediaContents]?)
    {
        self.kingfisherSource = []
        if let con = content {
            for x in con {
                if let p = x.path {
                    
                    let url = p.replacingOccurrences(of: " ", with: "%20")
                    let kingsource = KingfisherSource(urlString: url)
                    if let ks = kingsource {
                        self.kingfisherSource.append(ks)
                    }
                }
            }
        }
    }
    @IBAction func postActionButtonPressed(_ sender: UIButton) {
        self.delegateActions.DidSelectReportPost(tag: sender.tag)
    }
    
}

extension ImagePostCell: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        //print("current page:", page)
    }
}
