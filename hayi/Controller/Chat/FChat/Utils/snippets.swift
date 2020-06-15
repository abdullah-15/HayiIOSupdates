//
//    var data:[String] = ["Ali","Ahmed","Waqas","New User"]
//
//    let email = "abdullah5@gmail.com"
//    let lastname = "abdullah 5"
//    let firstname = "saeed"
//    let password = "abdullah123"



//FUser.registerUserWith(email: email, password: password, firstName: firstname, lastName: lastname) { (Error) in
//    if let error = Error {
//        print(error.localizedDescription)
//    }
//    else {
//        self.registerUser(name: self.firstname,surname: self.lastname)
//    }
//}
//
//func registerUser(name:String,surname:String) {
//    
//    let fullName = name + " " + surname
//    
//    let city = "Lahore"
//    let Country = "Pakistan"
//    let phone = "23423423"
//    
//    var tempDictionary : Dictionary = [kFIRSTNAME :name, kLASTNAME : surname, kFULLNAME : fullName, kCOUNTRY : Country, kCITY : city, kPHONE : phone] as [String : Any]
//    
//    
//    
//        imageFromInitials(firstName: name, lastName: surname) { (avatarInitials) in
//            
//            let avatarIMG = avatarInitials.jpegData(compressionQuality: 0.7)
//            let avatar = avatarIMG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
//            
//            tempDictionary[kAVATAR] = avatar
//            
//            self.finishRegistration(withValues: tempDictionary)
//        }
//        
//    
//
//}
//
//
//func finishRegistration(withValues: [String : Any]) {
//    
//    updateCurrentUserInFirestore(withValues: withValues) { (error) in
//        
//        if error != nil {
//            
//            DispatchQueue.main.async {
//                print(error!.localizedDescription)
//                print(error!.localizedDescription)
//            }
//            return
//        }
//    }
//    
//}
//
