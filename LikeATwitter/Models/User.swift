//
//  User.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 22.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import UIKit
import Firebase

struct User {
    let fullName: String
    let username: String
    let email: String
    let password: String?
    let profileImage: UIImage?
    var profileImageUrl: URL?
    let uid: String?
    var stats: UserReletionStats?
    var isFollowed = false
    
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == uid }
    
    init(fullName: String, username:String, email:String, password: String, profileImage: UIImage, profileImageUrl: URL? = nil, uid: String? = nil){
        self.email = email
        self.fullName = fullName
        self.password = password
        self.profileImage = profileImage
        self.username = username
        self.profileImageUrl = profileImageUrl
        self.uid = uid
    }
    
    init(uid: String, dictionary: [String:AnyObject], password: String? = nil, profileImage: UIImage? = nil) {
        self.uid = uid
        self.fullName = dictionary["fullName"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.password = password
        self.profileImage = profileImage
        
        if let profileImageUrlString = dictionary["profileImageUrl"] as? String {
            guard let url = URL(string: profileImageUrlString) else { return }
            self.profileImageUrl = url
        }
    }
}

struct UserReletionStats {
    let followers: Int
    let following: Int
}
