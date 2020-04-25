//
//  TextFieldView.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 21.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import UIKit

@IBDesignable
class TextFieldView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var seperatorLine: UIView!
    
    @IBInspectable var icon: UIImage? {
        didSet { imageView.image = icon}
    }
    
    @IBInspectable var placeholder: String? {
        didSet { textField.placeholder = placeholder }
    }
    
    @IBInspectable var themeColor: UIColor? {
        didSet {
            imageView.tintColor = themeColor
            seperatorLine.backgroundColor = themeColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configureView(){
        let bundle = Bundle(for: TextFieldView.self)
        bundle.loadNibNamed(String(describing: TextFieldView.self), owner: self, options: nil)
        
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}
