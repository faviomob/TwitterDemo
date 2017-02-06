//
//  User.swift
//  TwitterDemo
//
//  Created by Marat on 03/02/2017.
//  Copyright © 2017 Favio Mobile. All rights reserved.
//

import Foundation

var kCurrentUser: User?

extension User {
    
    var avatarNormalUrl: String {
        return "https://twitter.com/\(self.screenName!)/profile_image?size=bigger"
    }
    
    var avatarOriginalUrl: String {
        return "https://twitter.com/\(self.screenName!)/profile_image?size=original"
    }
    
    class var currentUser: User? {
        get {
            return kCurrentUser
        }
        set (user) {
            kCurrentUser = user
        }
    }
}
