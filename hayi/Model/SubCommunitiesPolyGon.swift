//
//  SubCommunitiesPolyGon.swift
//  hayi-ios2
//
//  Created by Mohsin on 17/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
import SwiftyJSON

class SubCommunities : NSObject {
    
    
   var  subCommunitiesID : Int?
    var name : String?
    var subCom : [ScShapes]?
    
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    /// Initiates the instance based on the JSON that was passed.
    ///
    /// - parameter json: JSON object from SwiftyJSON.
    public required init(json: JSON) {
        
        subCommunitiesID = (json["subCommunitiesID"].int)
        name =  (json["name"].string)
        let detail = json["scShapes"].array
        
        var array = [ScShapes]()
        for a in detail!
        {
            let obj = ScShapes(json: a)
            array.append(obj)
            
        }
        self.subCom = array
        
    }
}
