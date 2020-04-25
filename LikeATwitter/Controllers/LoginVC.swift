//
//  LoginVC.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 20.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: DataLoadingVC {

    @IBOutlet weak var emailTextField: TextFieldView!
    @IBOutlet weak var passwordTextField: TextFieldView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
 
    func configureViews() {
        emailTextField.textField.autocapitalizationType = .none
        emailTextField.textField.autocorrectionType = .no
        emailTextField.textField.keyboardType = .emailAddress
        emailTextField.textField.delegate = self
        
        passwordTextField.textField.autocorrectionType = .no
        passwordTextField.textField.isSecureTextEntry = true
        passwordTextField.textField.delegate = self
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        view.endEditing(true)
        guard let email = emailTextField.textField.text else { return }
        guard let password = passwordTextField.textField.text else { return }
        
        showLoadingView()
        AuthManager.shared.login(withemail: email, password: password) { (result, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else { return }
            guard let tab = window.rootViewController as? MainTabBarController else { return }
            
            tab.authenticateUserAndConfigureUI()
            self.dismissLoadingView()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func tapGestureAction(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField.textField {
            textField.resignFirstResponder()
            passwordTextField.textField.becomeFirstResponder()
        } else if textField == passwordTextField.textField {
            textField.resignFirstResponder()
        }
        return true
    }
}
