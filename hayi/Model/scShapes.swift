//
//  scShapes.swift
//  hayi-ios2
//
//  Created by Mohsin on 17/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
import SwiftyJSON

class ScShapes : NSObject {
    
    
    var subCommunityPolygonShapesID : Int?
     var latitude : Double?
    var longitude : Double?
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    /// Initiates the instance based on the JSON that was passed.
    ///
    /// - parameter json: JSON object from SwiftyJSON.
    public required init(json: JSON) {
        
        subCommunityPolygonShapesID = (json["subCommunityPolygonShapesID"].int)
        latitude =  (json["latitude"].double)
        longitude =  (json["longitude"].double)

        
        
    }
}
