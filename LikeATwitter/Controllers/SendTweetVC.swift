//
//  SendTweetVC.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 22.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import UIKit

class SendTweetVC: UIViewController {
    
    var user: User?
    
    let tweetButton = TweetButton()
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var tweetTextView: TweetTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureImageView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    @IBAction func cancelButtonAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func configureNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: tweetButton)
        tweetButton.addTarget(self, action: #selector(tweetButtonAction), for: .touchUpInside)
    }
    
    @objc func handleTextInputChange() {
        if tweetTextView.text.isEmpty {
            tweetTextView.placeholder.isHidden = false
            tweetButton.isUserInteractionEnabled = false
            tweetButton.backgroundColor = .lightGray
        } else {
            tweetTextView.placeholder.isHidden = true
            tweetButton.isUserInteractionEnabled = true
            tweetButton.backgroundColor = .systemOrange
        }
    }
    
    @objc func tweetButtonAction(){
        tweetButton.isEnabled = false
        guard let caption = tweetTextView.text else { return }
        
        TweetManager.shared.uploadTweet(caption: caption) { (error, ref) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func configureImageView(){
        avatarImage.layer.cornerRadius = avatarImage.frame.width / 2
        avatarImage.layer.masksToBounds = true
        guard let user = user else { return }
        
        avatarImage.sd_setImage(with: user.profileImageUrl, completed: nil)
        
    }
    
    @IBAction func tapGestureAction(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
