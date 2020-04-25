//
//  TweetCell.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 23.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import UIKit

protocol TweetCellDelegate {
    func didTapAvatarImage(_ user: User)
    func didTapLikeButton(cell: TweetCell)
}

class TweetCell: UITableViewCell {
    
    var user: User?
    
    var tweet : Tweet? {
        didSet { set() }
    }
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    var tweetCellDelegate: TweetCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureAvatarImage()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureAvatarImage() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarImageTapAction))
        avatarImage.layer.cornerRadius = avatarImage.frame.width / 2
        avatarImage.layer.masksToBounds = true
        avatarImage.addGestureRecognizer(tap)
        avatarImage.isUserInteractionEnabled = true
    }
    
    @objc func avatarImageTapAction() {
        guard let user = user else { return }
        tweetCellDelegate.didTapAvatarImage(user)
    }
    
    func set() {
        guard let tweet = tweet else { return }
        user = tweet.user
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        let date = formatter.string(from: tweet.timestamp, to: now) ?? "00"
        
        fullNameLabel.text = tweet.user.fullName
        usernameLabel.text = "@\(tweet.user.username)"
        
        dateLabel.text = "・\(date)"
        captionLabel.text = tweet.caption
        
        avatarImage.sd_setImage(with: user?.profileImageUrl, completed: nil)
        if tweet.didLike {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeButton.tintColor = .systemRed
        } else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            likeButton.tintColor = .secondaryLabel
        }
    }
    
    @IBAction func likeButtonAction(_ sender: UIButton) {
        tweetCellDelegate.didTapLikeButton(cell: self)
    }
}
