//
//  CollectionReference.swift
//  hayiChat
//
//  Created by MacBook Pro on 21/10/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import Foundation
import FirebaseFirestore


enum FCollectionReference: String {
    case User
    case Typing
    case Recent
    case Message
    case Group
    case Call
    
}
func reference(_ CollectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(CollectionReference.rawValue)
}
