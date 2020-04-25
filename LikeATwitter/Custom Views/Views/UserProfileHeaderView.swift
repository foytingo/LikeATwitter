//
//  UserProfileHeaderView.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 23.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import UIKit

protocol UserProfileHeaderDelegate {
    func handleProfileActionButton(_ header: UserProfileHeaderView)
    func showTweets()
    func showLikes()
}

@IBDesignable
class UserProfileHeaderView: UIView {

    @IBOutlet var view: UIView!
   
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var user: User? {
        didSet { set()
        }
    }
    
    var actionButtonTitle: String {
        if let user = user {
            if user.isCurrentUser {
                return "Edit Profile"
            } else if !user.isFollowed && !user.isCurrentUser {
                return "Follow"
            } else if user.isFollowed {
                return "Unfollow"
            } else {
                return "Error"
            }
        }
        return "Error"
    }
    
    var delegate: UserProfileHeaderDelegate!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureAvatarImage()
        configureActionButton()
        segmentControl.selectedSegmentIndex = 0
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
        configureAvatarImage()
        configureActionButton()
        
        
    }
    
    func configureView() {
        let bundle = Bundle(for: UserProfileHeaderView.self)
        bundle.loadNibNamed(String(describing: UserProfileHeaderView.self), owner: self, options: nil)
        
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func configureAvatarImage(){
        avatarImage.layer.cornerRadius = avatarImage.frame.width / 2
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.borderWidth = 2
        avatarImage.layer.borderColor = UIColor.systemBackground.cgColor
    }
    
    func configureActionButton() {
        actionButton.layer.cornerRadius = actionButton.frame.height / 2
        actionButton.layer.masksToBounds = true
        actionButton.layer.borderWidth = 1
        actionButton.layer.borderColor = UIColor.systemOrange.cgColor
        actionButton.setTitle("Loading", for: .normal)
        
    }
    
    
    @IBAction func actionButtonAction(_ sender: UIButton) {
        delegate.handleProfileActionButton(self)
    }
    
    @IBAction func segmentControlAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            delegate.showTweets()
            break
        case 1:
            delegate.showLikes()
            break
        default:
            print("error")
            break
        }
    }
    
    func set() {
        guard let user = user else { return }
        avatarImage.sd_setImage(with: user.profileImageUrl, completed: nil)
        fullNameLabel.text = user.fullName
        usernameLabel.text = "@\(user.username)"
        followerCount.text = "\(user.stats?.followers ?? 0)"
        followingCount.text = "\(user.stats?.following ?? 0)"
        actionButton.setTitle(actionButtonTitle, for: .normal)
    }
}
