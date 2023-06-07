//
//  RegistrationViewController.swift
//  FunctionFinder
//
//  Created by Justin Wong on 5/26/23.
//

import UIKit
import SafariServices

class RegistrationViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Subviews
    
    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .lightGray
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 45
        return imageView
    }()

    private let usernameField: TextField = {
        let field = TextField()
        field.placeholder = "Username..."
        field.returnKeyType = .next
        field.keyboardType = .default
        field.autocorrectionType = .no
        return field
    }()
    
    private let emailField: TextField = {
        let field = TextField()
        field.placeholder = "Email Address..."
        field.returnKeyType = .next
        field.keyboardType = .emailAddress
        field.autocorrectionType = .no
        return field
    }()
    
    private let passwordField: TextField = {
        let field = TextField()
        field.isSecureTextEntry = true
        field.placeholder = "Password..."
        field.returnKeyType = .continue
        field.keyboardType = .default
        field.autocorrectionType = .no
        return field
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let termsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Terms of Service", for: .normal)
        button.setTitleColor(.secondaryLabel, for: .normal)
        return button
    }()
    
    private let privacyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Privacy Policy", for: .normal)
        button.setTitleColor(.secondaryLabel, for: .normal)
        return button
    }()
    
    public var completion: (() -> Void)?
    
    // MARK: - Lifestyle00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = .systemBackground
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        addSubviews()
        addButtonActions()
        addImageGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageSize: CGFloat = 90
    
        profilePictureImageView.frame = CGRect(x: (view.width - imageSize)/2, y: view.safeAreaInsets.top + 15, width: imageSize, height: imageSize)
        usernameField.frame = CGRect(x: 25, y: profilePictureImageView.bottom + 20, width: view.width - 50, height: 50)
        emailField.frame = CGRect(x: 25, y: usernameField.bottom + 10, width: view.width - 50, height: 50)
        passwordField.frame = CGRect(x: 25, y: emailField.bottom + 10, width: view.width - 50, height: 50)
        registerButton.frame = CGRect(x: 25, y: passwordField.bottom + 20, width: view.width - 50, height: 50)
        termsButton.frame = CGRect(x: 10, y: view.height - view.safeAreaInsets.bottom - 100, width: view.width - 20, height: 50)
        privacyButton.frame = CGRect(x: 10, y: view.height - view.safeAreaInsets.bottom - 50, width: view.width - 20, height: 50)
    }
    
    private func addSubviews(){
        view.addSubview(profilePictureImageView)
        view.addSubview(usernameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(registerButton)
        view.addSubview(termsButton)
        view.addSubview(privacyButton)
    }
    
    private func addImageGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        profilePictureImageView.isUserInteractionEnabled = true
        profilePictureImageView.addGestureRecognizer(tap)
    }
    
    private func addButtonActions(){
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTermsButton), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapPrivacyButton), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc func didTapImage() {
        let sheet = UIAlertController(title: "Profile Picture",
                                      message: "Set a picture to help your friends find you.",
                                      preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = true
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        sheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        
        present(sheet, animated: true)
    }
    
    @objc private func didTapRegister() {
        emailField.resignFirstResponder()
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text,
              let username = usernameField.text,
              let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6,
              username.trimmingCharacters(in: .alphanumerics).isEmpty
        else {
            presentError()
            return
        }
        
        let data = profilePictureImageView.image?.pngData()
        
        // Sign up with AuthManager
        AuthManager.shared.registerNewUser(username: username, email: email, password: password, profilePicture: data) { [weak self] registered in
            DispatchQueue.main.async {
                switch registered {
                case .success(let user):
                    UserDefaults.standard.setValue(user.email, forKey: "email")
                    UserDefaults.standard.setValue(user.username, forKey: "username")
                    
                    self?.navigationController?.popToRootViewController(animated: true)
                    self?.completion?()
                case .failure(let error):
                    print("\n\nSign Up Error: \(error)")
                }
            }
        }
    }
    
    private func presentError() {
        let alert = UIAlertController(title: "Whoops", message: "Please make sure to fill all fields and have a password longer than 6 characters.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapTermsButton() {
        guard let url = URL(string: "https://help.instagram.com/581066165581870") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    @objc private func didTapPrivacyButton() {
        guard let url = URL(string: "https://help.instagram.com/155833707900388") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }

    // MARK: Field Delegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            didTapRegister()
        }
        return true
    }
    
    // Image Picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        profilePictureImageView.image = image
    }
}
