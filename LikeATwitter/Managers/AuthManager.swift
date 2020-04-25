//
//  AuthManager.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 22.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import Foundation
import Firebase

struct AuthManager {
    static let shared = AuthManager()
    
    func login(withemail email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func register(with userData: User, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let profileImage = userData.profileImage else { return }
        guard let imageData = profileImage.jpegData(compressionQuality: 0.3) else { return }
        let fileName = NSUUID().uuidString
        let storageRef = Refs.storageProfileImages.child(fileName)
        storageRef.putData(imageData, metadata: nil) { (meta, error) in
            storageRef.downloadURL { (url, error) in
                guard let password = userData.password else { return }
                guard let profileImageUrl = url?.absoluteString else { return }
                Auth.auth().createUser(withEmail: userData.email, password: password) { (result, error) in
                    if let error = error {
                        print("Error is \(error.localizedDescription)")
                        return
                    }
                    guard let uid = result?.user.uid else { return }
                    let values = ["email": userData.email, "username": userData.username, "fullName": userData.fullName, "profileImageUrl": profileImageUrl]
                    Refs.users.child(uid).updateChildValues(values, withCompletionBlock: completion)
                    print("Create user info in db")
                    
                }
                print("Profile image added user info")
            }
            print("Profile image stored started")
        }
        
        print("Registration started")
    }
}
