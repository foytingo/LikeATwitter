//
//  Constants.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 22.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import Foundation
import Firebase

enum Refs {
    static let storage = Storage.storage().reference()
    static let storageProfileImages = storage.child("profile_images")
    
    static let db = Database.database().reference()
    static let users = db.child("users")
    static let tweets = db.child("tweets")
    static let userTweets = db.child("user-tweets")
    static let userFollowers = db.child("user-followers")
    static let userFollowing = db.child("user-following")
    static let userLikes = db.child("user-likes")
    static let tweetLikes = db.child("tweet-likes")
}
