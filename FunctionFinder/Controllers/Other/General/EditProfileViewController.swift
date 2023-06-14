//
//  EditProfileViewController.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/1/23.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    public var completion: (() -> Void)?
    
    // Fields
    let nameField: TextField = {
        let field = TextField()
        field.placeholder = "Name..."
        return field
    }()
    
    private let bioTextView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        textView.backgroundColor = .secondarySystemBackground
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Profile"
        view.backgroundColor = .systemBackground
        view.addSubview(nameField)
        view.addSubview(bioTextView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(didTapSave)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
        
        guard let username = UserDefaults.standard.string(forKey: "username")
        else {
            return
        }
        DatabaseManager.shared.getUserInfo(username: username) { [weak self] info in
            DispatchQueue.main.async {
                if let info = info {
                    self?.nameField.text = info.name
                    self?.bioTextView.text = info.bio
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nameField.frame = CGRect(x: 20,
                                 y: view.safeAreaInsets.top + 10,
                                 width: view.width - 40,
                                 height: 50)
        bioTextView.frame = CGRect(x: 20,
                                   y: nameField.bottom + 10,
                                   width: view.width - 40,
                                   height: 120)
    }
    
    // Actions
    
    @objc private func didTapSave() {
        let name = nameField.text ?? ""
        let bio = bioTextView.text ?? ""
        let newInfo = UserInfo(name: name, bio: bio)
        DatabaseManager.shared.setUserInfo(userInfo: newInfo) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.completion?()
                    self?.didTapClose()
                }
            }
        }
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
}
