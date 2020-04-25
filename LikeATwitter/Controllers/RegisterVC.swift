//
//  RegisterVC.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 21.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import UIKit

class RegisterVC: DataLoadingVC {
    @IBOutlet weak var usernameTextField: TextFieldView!
    @IBOutlet weak var fullNameTextField: TextFieldView!
    @IBOutlet weak var emailTextField: TextFieldView!
    @IBOutlet weak var passwordTextField: TextFieldView!
    @IBOutlet weak var confirmPasswordTextField: TextFieldView!
    
    @IBOutlet weak var addPhotoButton: UIButton!
    
    private let imagePicker = UIImagePickerController()
    private var profileImage = UIImage(named: "avatarPlaceHolder")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    func configureViews(){
        usernameTextField.textField.delegate = self
        usernameTextField.textField.autocorrectionType = .no
        
        fullNameTextField.textField.autocorrectionType = .no
        fullNameTextField.textField.delegate = self
        
        emailTextField.textField.autocorrectionType = .no
        emailTextField.textField.autocapitalizationType = .none
        emailTextField.textField.keyboardType = .emailAddress
        emailTextField.textField.delegate = self
        
        passwordTextField.textField.autocorrectionType = .no
        passwordTextField.textField.isSecureTextEntry = true
        passwordTextField.textField.delegate = self
        
        confirmPasswordTextField.textField.autocorrectionType = .no
        confirmPasswordTextField.textField.isSecureTextEntry = true
        confirmPasswordTextField.textField.delegate = self
        
        
    }
    
    
    @IBAction func addPhotoButtonAction(_ sender: UIButton) {
        present(imagePicker, animated: true)
    }
    
    
    @IBAction func signUpButtonAction(_ sender: UIButton) {
        guard let fullName = fullNameTextField.textField.text else { return }
        guard let username = usernameTextField.textField.text else { return }
        guard let email = emailTextField.textField.text else { return }
        guard let password = passwordTextField.textField.text else { return }
        guard let confirmPassword = confirmPasswordTextField.textField.text else { return }
        guard let profileImage = profileImage else { return }
        
        if password != confirmPassword {
            print("Password can't confirm. Check your password.")
            return
        }

        
        //Set default profile photo if didnt set by user
        //Show alert for that situation
        
        let user = User(fullName: fullName, username: username, email: email, password: password, profileImage: profileImage)
        print(user)
        showLoadingView()
        AuthManager.shared.register(with: user) { (error, ref) in
            
            guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else { return }
            guard let tab = window.rootViewController as? MainTabBarController else { return }
            
            tab.authenticateUserAndConfigureUI()
            self.dismissLoadingView()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    

    @IBAction func haveAccountButtonAction(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func tapGestureAction(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}

extension RegisterVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        self.profileImage = profileImage
        
        addPhotoButton.layer.cornerRadius = addPhotoButton.frame.size.width / 2
        addPhotoButton.layer.masksToBounds = true
        addPhotoButton.imageView?.contentMode = .scaleToFill
        addPhotoButton.imageView?.clipsToBounds = true
        addPhotoButton.layer.borderColor = UIColor.systemOrange.cgColor
        addPhotoButton.layer.borderWidth = 3
        
        self.addPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
}

extension RegisterVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField.textField {
            textField.resignFirstResponder()
            fullNameTextField.textField.becomeFirstResponder()
        } else if textField == fullNameTextField.textField {
            textField.resignFirstResponder()
            emailTextField.textField.becomeFirstResponder()
        } else if textField == emailTextField.textField {
            textField.resignFirstResponder()
            passwordTextField.textField.becomeFirstResponder()
        } else if textField == passwordTextField.textField {
            textField.resignFirstResponder()
            confirmPasswordTextField.textField.becomeFirstResponder()
        } else if textField == confirmPasswordTextField.textField {
            textField.resignFirstResponder()
        }
        return true
    }
}
