//
//  AllButton.swift
//  hayi-ios2
//
//  Created by Mohsin on 16/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
import SwiftyJSON

class SubCommunitiesButton : NSObject {
    
    
    var subCommunitiesID : Int?
    var name: String?
    var latitude : String?
    var longitude : String?
    var members : Int?
    
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    /// Initiates the instance based on the JSON that was passed.
    ///
    /// - parameter json: JSON object from SwiftyJSON.
    public required init(json: JSON) {
        
        subCommunitiesID = (json["subCommunitiesID"].int)
        name =  (json["name"].string)
        latitude = (json["latitude"].string)
        longitude = (json["longitude"].string )
        members = (json["members"].int )
       
    
    }
}
