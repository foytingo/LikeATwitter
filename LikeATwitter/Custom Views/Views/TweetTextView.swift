//
//  TweetTextView.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 22.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import UIKit

class TweetTextView: UITextView {

    let placeholder = UILabel()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
     
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
        configurePlaceholder()
    }
    
    func configure(){
        backgroundColor = .systemBackground
        font = UIFont.systemFont(ofSize: 16)
        isScrollEnabled = false
        becomeFirstResponder()
        isScrollEnabled = false
        
        //NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    @objc func handleTextInputChange() {
        placeholder.isHidden = !text.isEmpty
    }
    
    func configurePlaceholder() {
        addSubview(placeholder)
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholder.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            placeholder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
        
        ])
        placeholder.font = UIFont.systemFont(ofSize: 16)
        placeholder.textColor = .placeholderText
        placeholder.text = "What's happening?"
    }

}
