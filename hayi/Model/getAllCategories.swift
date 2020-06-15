//
//  getAllCategories.swift
//  hayi-ios2
//
//  Created by Mohsin on 04/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
import SwiftyJSON
class AllCategories : Codable {
    
    var postCategoriesId : Int?
    var name: String?
    
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    /// Initiates the instance based on the JSON that was passed.
    ///
    /// - parameter json: JSON object from SwiftyJSON.
    public required init(json: JSON) {
        
        postCategoriesId = (json["postCategoriesId"].int)
        name =  (json["name"].string)
    }
    public init (categoryId: Int, name:String){
        self.postCategoriesId = categoryId
        self.name =  name
    }
        
}
