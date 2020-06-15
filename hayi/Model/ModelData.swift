//
//  ModelData.swift
//  hayi-ios2
//
//  Created by Mohsin on 17/09/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation


struct Login: Codable {
    var token : String?
    var expireAt : String?
    var userId : Int?
    var neighbourHoodId : Int?
    var subCommunityId : Int?
    var response  = Response()
    
    
}
struct Response: Codable {
    var status : Int?
    var result : Bool?
    var msg : String?
  
}

extension Response {
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case result = "result"
        case msg = "msg"
       
        
    }
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decode(Int.self, forKey: .status)
        result = try values.decode(Bool.self, forKey: .result)
        msg = try values.decode(String.self, forKey: .msg)
       
        
    }
    
}

extension Login {
    enum CodingKeys: String, CodingKey {
       // case token = "token"
        case expireAt = "expireAt"
        case userId = "userId"
        case neighbourHoodId = "neighbourHoodId"
        case subCommunityId = "subCommunityId"
        case response = "requestResponse"


    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
       // token = try values.decode(String.self, forKey: .token)
        expireAt = try values.decode(String.self, forKey: .expireAt)
        userId = try values.decode(Int.self, forKey: .userId)
        neighbourHoodId = try values.decode(Int.self, forKey: .neighbourHoodId)
        subCommunityId = try values.decode(Int.self, forKey: .subCommunityId)
        response = try values.decode(Response.self, forKey: .response)


    }
    
}
