//
//  MainTabBarController.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 22.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MainTabBarController: UITabBarController {
    
    var user: User?
    
    var uid: String? {
        didSet {
            guard let nav = viewControllers?[0] as? UINavigationController else { return }
            guard let feed = nav.viewControllers[0] as? FeedVC else { return }
            feed.uid = uid
            guard let nav2 = viewControllers?[2] as? UINavigationController else { return }
            guard let like = nav2.viewControllers[0] as? LikeVC else { return }
            like.uid = uid
        }
    }
    
    let stickyButton = StickyTweetButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //logUserOut()
        authenticateUserAndConfigureUI()
    }
    
    func configureStickyButton() {
        let buttonSize : CGFloat = 56
        
        view.addSubview(stickyButton)
        NSLayoutConstraint.activate([
            stickyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stickyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64),
            stickyButton.heightAnchor.constraint(equalToConstant: buttonSize),
            stickyButton.widthAnchor.constraint(equalToConstant: buttonSize)
        ])
        
        stickyButton.layer.cornerRadius = buttonSize / 2
        stickyButton.setImage(UIImage(systemName: "text.badge.plus"), for: .normal)
        stickyButton.addTarget(self, action: #selector(stickyButtonAction), for: .touchUpInside)
    }
    
    @objc func stickyButtonAction() {
        performSegue(withIdentifier: "goToSendTweet", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           
           if segue.identifier == "goToSendTweet" {
               guard let user = user else { return }
               guard let destNav = segue.destination as? UINavigationController else { return }
               guard let destVC = destNav.topViewController as? SendTweetVC else { return }
               destVC.user = user
           }
           
       }
    
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToAuth", sender: nil)
            }
        } else {
            configureStickyButton()
            fetchUser()
        }
    }
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.uid = uid
        UserManager.shared.fetchUser(uid: uid) { (user) in
            self.user = user
        }
        
    }
    
    func logUserOut() {
        do{
            try Auth.auth().signOut()
        } catch let error {
            print("Failed to sing out \(error.localizedDescription)")
        }
    }
    
}
