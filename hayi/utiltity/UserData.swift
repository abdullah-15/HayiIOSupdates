//
//  UserData.swift
//  hayi-ios2
//
//  Created by Mohsin on 01/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
class saveUser : NSObject  , NSCoding{
    
    
     var name: String!
     var id: Int!
    init(name: String, id: Int) {
        self.name = name
        self.id = id
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(id, forKey: "id")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name =  aDecoder.decodeObject(forKey: "name") as! String
        let id = aDecoder.decodeObject(forKey: "id") as! Int
        self.init(name: name, id: id)
    }
    
    
}
