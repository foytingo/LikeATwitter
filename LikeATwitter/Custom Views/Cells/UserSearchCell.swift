//
//  UserSearchCell.swift
//  Twitter-Clone-
//
//  Created by Murat Baykor on 17.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import UIKit

class UserSearchCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.layer.masksToBounds = true
        avatarImageView.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(user: User) {
        
        avatarImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        
        usernameLabel.text = user.username
        nameLabel.text = user.fullName
    }
    
}
