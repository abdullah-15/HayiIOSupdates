
import Foundation

public class UserDefaultsManager {
    
    
    internal static let instance  = UserDefaultsManager()
    
    func SaveLoginDetails(email: String, password: String, profileStatus: Int,userId: Int,neighbourHoodId: Int, subCommunityId: Int) {
        UserDefaults.standard.setValue(profileStatus, forKey: KeyProfileStatus)
        UserDefaults.standard.setValue(email, forKey: KeyEmail)
        UserDefaults.standard.setValue(password, forKey: KeyPassword)
        UserDefaults.standard.setValue(email, forKey: KeyUsername )
        UserDefaults.standard.set(userId, forKey: KeyUserId)
        UserDefaults.standard.setValue(neighbourHoodId, forKey: KeyNeighbourHoodId)
        UserDefaults.standard.setValue(subCommunityId, forKey: KeySubCommunityId)
        UserDefaults.standard.set(true, forKey: KeyLoginState)
        
        
        
    }
    
    func SaveUserProfile(data: NSDictionary,skills:NSArray?,interests:NSArray?) {
        
        let firstName = data.value(forKey: KeyFirstName) as? String
        let lastName = data.value(forKey: KeyLastName) as? String
        let gender =  data.value(forKey: KeyGender) as? String
        let profileImage =  data.value(forKey: KeyProfileImage) as? String
        let residentSince =  data.value(forKey: KeyResidentSince) as? String
        let nationality =  data.value(forKey: KeyNationality) as? String
        let jobTile =  data.value(forKey: KeyJobTitle) as? String
        let address =  data.value(forKey: keyAddress) as? String
        let externalChatId =  data.value(forKey: KeyExternalChatId) as? String
        
        let neighbourHood =  data.value(forKey: KeyNeighbourHood) as? String
        let subCommunity =  data.value(forKey: KeySubCommunity) as? String
        
        
        UserDefaults.standard.setValue(firstName, forKey: KeyFirstName)
        UserDefaults.standard.setValue(lastName, forKey: KeyLastName)
        UserDefaults.standard.setValue(gender, forKey: KeyGender)
        UserDefaults.standard.setValue(profileImage, forKey: KeyProfileImage)
        UserDefaults.standard.setValue(residentSince, forKey: KeyResidentSince)
        UserDefaults.standard.setValue(nationality, forKey: KeyNationality)
        UserDefaults.standard.setValue(jobTile, forKey: KeyJobTitle)
        UserDefaults.standard.setValue(address, forKey: keyAddress)
        UserDefaults.standard.setValue(externalChatId, forKey: KeyExternalChatId)
        UserDefaults.standard.setValue(skills, forKey: keySkills)
        UserDefaults.standard.setValue(interests, forKey: keyInterests)
        UserDefaults.standard.setValue(neighbourHood, forKey: KeyNeighbourHood)
        UserDefaults.standard.setValue(subCommunity, forKey: KeySubCommunity)
        
       // UserDefaults.standard.setva
        UserDefaults.standard.set(true,forKey: KeyIsProfileLoaded)
        
        UserDefaults.standard.synchronize()
        
    }
    
    func UpdateUserInterest(interests:NSArray?) {
        UserDefaults.standard.setValue(interests, forKey: keyInterests)
    }
    
    
    func isloggedin() -> Bool{
        
        let  loginstate  =  UserDefaults.standard.bool(forKey: KeyLoginState)
        
        if loginstate  {
            return true
        }else{
            return false
        }
    }
    
    func getValueFor(key:String) -> String? {
        
        return UserDefaults.standard.value(forKey: key) as? String
    }
    
    func setValueFor(value: String?,key:String) {
         UserDefaults.standard.setValue(value,forKey: key)
    }
    
    func getNeighbourHoodId() -> Int? {
        return UserDefaults.standard.value(forKey: KeyNeighbourHoodId) as? Int
    }
    func getSubCommunityId() -> Int? {
        return UserDefaults.standard.value(forKey: KeySubCommunityId) as? Int
    }
    func getFullName() -> String {
        
        let firstName = UserDefaults.standard.value(forKey: KeyFirstName) as! String
        
        let lastName = UserDefaults.standard.value(forKey: KeyLastName) as! String
        
        return  firstName + " " + lastName
    }
    
    func getValueUnwrappedFor(key:String) -> String {
        
        return UserDefaults.standard.value(forKey: key) as! String
    }
    
    func getInterests() -> NSArray {
        
        let array =  UserDefaults.standard.value(forKey: keyInterests) as? NSArray
        
        if array != nil {
            
            return array!
        }
        else
        {
            return NSArray()
        }
    }
    
    func getSkills() -> NSArray {
        
        let array =  UserDefaults.standard.value(forKey: keySkills) as? NSArray
        
        if array != nil {
            
            return array!
        }
        else
        {
            return NSArray()
        }
    }
    
    
    func getuserdetaild (key : String)-> String?
    {
        
        return  UserDefaults.standard.string(forKey: key)!
    }
    func CurrentUserId() -> Int? {
        
        return UserDefaults.standard.value(forKey: KeyUserId) as? Int
    }
    
    
    func logOut(){
        
        
        let defaults =  UserDefaults.standard
        defaults.removeObject(forKey: KeyUserId)
        defaults.removeObject(forKey: KeyFirstName)
        defaults.removeObject(forKey: KeyLastName)
        defaults.removeObject(forKey: KeyGender)
        defaults.removeObject(forKey: KeyNeighbourHoodId)
        defaults.removeObject(forKey: KeySubCommunityId)
        defaults.removeObject(forKey: KeyProfileImage)
        defaults.removeObject(forKey: KeyResidentSince)
        defaults.removeObject(forKey: KeyNationality)
        defaults.removeObject(forKey: KeyJobTitle)
        defaults.removeObject(forKey: keyAddress)
        defaults.removeObject(forKey: KeyExternalChatId)
        
        defaults.removeObject(forKey: KeyProfileStatus)
        defaults.removeObject(forKey: KeyEmail)
        defaults.removeObject(forKey: KeyUsername)
        defaults.removeObject(forKey: KeyPassword)
        
        defaults.set(false, forKey: KeyLoginState)
        defaults.set(false, forKey: KeyIsProfileLoaded)
        
    }
    
}
