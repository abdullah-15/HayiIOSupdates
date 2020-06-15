//
//  URL.swift
//  hayi
//
//  Created by MacBook Pro on 16/12/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
extension URL {
    func formatURL()->URL {
        
        let str = self.absoluteString
        if str.starts(with: "http") || str.starts(with: "https")
        {
            return self
        }
        else {
            return URL.init(string: "http://" + self.absoluteString) ?? self
        }
    }
}
