//
//  TweetButton.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 22.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import UIKit

class TweetButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(){
        backgroundColor = .lightGray
        isUserInteractionEnabled = false
        setTitle("Tweet", for: .normal)
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        setTitleColor(.white, for: .normal)
        
        frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        layer.cornerRadius = 32 / 2
        
    }
    
}
