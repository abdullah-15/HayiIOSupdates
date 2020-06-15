//
//  Helper.swift
//


import Foundation
import UIKit
import Alamofire
var internetNot  = "You are not connected with Internet!."
let baseUrl = "https://api.hayi.app/api/"
//let baseUrl = "https://dev-api.hayi.app/api/"

struct HelperFuntions {
    
    static let getBoundries            =  baseUrl + "Neighbourhood/GetNeighbourMapRestrictionById"
    static let getNeighbour            =  baseUrl + "Neighbourhood/GetNeighbourHoods"
    static let getNeighbourHoodPolygone = baseUrl + "Neighbourhood/GetNeighbourHoodPolygone"
    static let GetNoofMembersinNeighbourhood = baseUrl + "Neighbourhood/GetNoofMembersinNeighbourhood"
    
    static let getSubCommunites        = baseUrl + "SubCommunity/GetAllSubCommunitiesWithShapes?id="
    static let subCommun               = baseUrl + "SubCommunity/GetSubCommunities"
    static let getAllbuttons           = baseUrl + "SubCommunity/GetSubCommunitiesButtons?id="

    static let register                = baseUrl +   "Account/Register"
    static let signIn                  = baseUrl +  "Account/Signin"
    static let updatePassword          = baseUrl +  "Account/UpdatePassword"
    static let forgotPasswords         = baseUrl +  "Account/ForgetPassword"
    
    static let makaninumber            = baseUrl +  "Address/VerifyAddressByMakani"
    static let document                = baseUrl +  "Address/VerifyAddressByDocs"
    static let location                = baseUrl +  "Address/VerifyAddressByLocation"
    
    static let imagePost               = baseUrl +  "ImageResource/Post"

    static let getProfile              = baseUrl +  "User/GetUserProfile"
    static let updateBio               = baseUrl +  "User/UpdateBio"
    static let updateInterest          = baseUrl +  "UserInterestSkill/UpdateUserInterests"
    static let updateSkilss            = baseUrl +  "UserInterestSkill/UpdateUserSkills"
    static let getAllUser              = baseUrl +  "User/GetAllUsersByFilters"
    static let updateProfileImage      = baseUrl +  "User/UpdateProfileImage"
    static let SaveExternalChatId      = baseUrl +  "User/SaveExternalChatId"
    
    static let getAllInterest          = baseUrl +  "Interest/GetAllInterests"
    static let getAllSkilss            = baseUrl +  "Skill/GetAllSkills"
    
    static let loadPosts               = baseUrl +  "Post/GetAllPostsByNeighBorhoodID"
    static let getAllcategories        = baseUrl +  "Post/GetAllPostCategories"
    static let creatpost               = baseUrl +  "Post/CreatePost"
    static let createPostComment       = baseUrl +  "Post/CreatePostComment"
    static let deletePostComment       = baseUrl +  "Post/DeletePostComment"
    static let DeletePost              = baseUrl +  "Post/DeletePost"
    static let getPostDetailsByID      = baseUrl +  "Post/GetPostDetailsByID"
    static let reportPost              = baseUrl +  "Post/ReportPost"
    static let PostLikeUnlike          = baseUrl + "Post/PostLikeUnlike"
    
    static let getNotificationOptions  = baseUrl +  "Notifications/GetNotificationOption?userId="
    static let getNotifications        = baseUrl +  "Notifications/GetNotifications"
    static let MuteAllNotificationOption = baseUrl + "Notifications/MuteAllNotificationOption"
    static let UpdateNotificationOption = baseUrl +  "Notifications/UpdateNotificationOption"
    static let UpdateUserFCMToken       = baseUrl +  "Notifications/UpdateUserFCMToken"
    static let GetFCMTokensByExternalChatIds = baseUrl + "Notifications/GetFCMTokensByExternalChatIds"
    
    
    static var storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    static var Profile: UIStoryboard = UIStoryboard(name: "Profile", bundle: Bundle.main)

    static func validateRequiredField(_ text: String)-> Bool {
        
        var isValid = true
        let strText = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (strText == "") {
            
            isValid = false
        }
        
        return isValid
        
    }
    static func showAlert(_ title:String, withMessage:String){
        
        struct Alert {
            
            static var alert : UIAlertView?
            
        }
        if Alert.alert == nil {
            
            Alert.alert = UIAlertView()
        }
        let alert = Alert.alert
        alert!.title = title
        alert!.message = withMessage
        alert!.addButton(withTitle: "OK")
        alert!.show()
        
    }
   
}

struct AppManager {
    
    static var invoicedata:NSArray? = NSArray()
    static var userposts  = [post]()
    static var neighbourHoodId:Int?
    static var neighbourHoodName: String?
    static  var subcommunID:Int?
    static var subCommunityName: String?
    static var firstName:String?
    static var familyName:String?
    static var genderId:Int?
    static var email:String?
    static var password:String?
    static var healthID : Int?
    static var courseID : Int?
    static var trainderID : Int?
    static var categoryID : Int = 0
    static var postID : Int?
    static var likeCount : Int?
    static var LikepostID : Int?
    static var globalCheck : Int?
    static var CategoryName : String = "All Activities"
    static var shouldLoadPostsAgain: Bool = false
    static var categories = [AllCategories]()
    static var isCategoriesLoaded = false
    static var shouldUpdateCommentsCount = false
    static var PostindexUpdated = 0

}


class Connectivity{
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

