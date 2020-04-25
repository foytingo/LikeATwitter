//
//  UserManager.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 22.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import Foundation
import Firebase

struct UserManager {
    static let shared = UserManager()
    
    func fetchUser(uid: String, completion: @escaping(User) -> Void) {
        Refs.users.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
    
    func fetchUsers(completion: @escaping([User]) -> Void) {
        var users = [User]()
        Refs.users.observe(.childAdded) { (snapshot) in
            let uid = snapshot.key
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            users.append(user)
            completion(users)
            
        }
    }
    
    func followUser(uid: String, completion: @escaping(Error?, DatabaseReference)->Void){
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Refs.userFollowing.child(currentUid).updateChildValues([uid:1]) { (error, ref) in
            Refs.userFollowers.child(uid).updateChildValues([currentUid:1], withCompletionBlock: completion)
        }
    }
    
    func unfollowUser(uid: String, completion: @escaping(Error?, DatabaseReference)->Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Refs.userFollowing.child(currentUid).child(uid).removeValue { (error, ref) in
            Refs.userFollowers.child(uid).child(currentUid).removeValue(completionBlock: completion)
        }
    }
    
    func checkIfUserFollowed(uid: String, completion: @escaping(Bool)->Void){
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Refs.userFollowing.child(currentUid).child(uid).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
    }
    
    func fetchUserStats(uid: String, completion: @escaping(UserReletionStats)->Void){
        Refs.userFollowers.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            let followers = snapshot.children.allObjects.count
            
            Refs.userFollowing.child(uid).observeSingleEvent(of: .value) { (snapshot) in
                let following = snapshot.children.allObjects.count
                
                let stats = UserReletionStats(followers: followers, following: following)
                completion(stats)
            }
        }
    }
}
