//
//  SettingsViewController.swift
//  FunctionFinder
//
//  Created by Justin Wong on 5/30/23.
//

import UIKit
import SafariServices

/// View Controller to show user settings
final class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .grouped)
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var sections: [SettingsSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        configureModels()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
        createTableFooter()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    private func configureModels() {
//        data.append([
//            SettingCellModel(title: "Edit Profile") { [weak self] in
//                self?.didTapEditProfile()
//            },
//            SettingCellModel(title: "Invite Friends") { [weak self] in
//                self?.didTapInviteFriends()
//            },
//            SettingCellModel(title: "Save Original Posts") { [weak self] in
//                self?.didTapSaveOriginalPosts()
//            }
//        ])
//        data.append([
//            SettingCellModel(title: "Terms of Service") { [weak self] in
//                self?.openURL(type: .terms)
//            },
//            SettingCellModel(title: "Privacy Policy") { [weak self] in
//                self?.openURL(type: .privacy)
//            },
//            SettingCellModel(title: "Help / Feedback") { [weak self] in
//                self?.openURL(type: .help)
//            }
//        ])
        sections.append(
            SettingsSection(title: "App", options: [
                SettingOption(
                    title: "Rate App",
                    image: UIImage(systemName: "star"),
                    color: .systemOrange
                ) {
                    guard let url = URL(string: "https://apps.apple.com/us/app/instagram/id389801252")
                    else {
                        return
                    }
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                },
                SettingOption(
                    title: "Share App",
                    image: UIImage(systemName: "square.and.arrow.up"),
                    color: .systemBlue
                ) { [weak self] in
                    guard let url = URL(string: "https://apps.apple.com/us/app/instagram/id389801252")
                    else {
                        return
                    }
                    DispatchQueue.main.async {
                        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
                        self?.present(vc, animated: true)
                    }
                }
            ])
        )
        
        sections.append(
            SettingsSection(title: "Information", options: [
                SettingOption(
                    title: "Terms of Service",
                    image: UIImage(systemName: "doc"),
                    color: .systemPink
                ) { [weak self] in
                    DispatchQueue.main.async {
                        guard let url = URL(string: "https://help.instagram.com/581066165581870")
                        else {
                            return
                        }
                        let vc = SFSafariViewController(url: url)
                        self?.present(vc, animated: true, completion: nil)
                    }
                },
                SettingOption(
                    title: "Privacy Policy",
                    image: UIImage(systemName: "hand.raised.fill"),
                    color: .systemGreen
                ) { [weak self] in
                    DispatchQueue.main.async {
                        guard let url = URL(string: "https://help.instagram.com/155833707900388")
                        else {
                            return
                        }
                        let vc = SFSafariViewController(url: url)
                        self?.present(vc, animated: true, completion: nil)
                    }
                },
                SettingOption(
                    title: "Get Help",
                    image: UIImage(systemName: "message"),
                    color: .systemPurple
                ) { [weak self] in
                    DispatchQueue.main.async {
                        guard let url = URL(string: "https://help.instagram.com/")
                        else {
                            return
                        }
                        let vc = SFSafariViewController(url: url)
                        self?.present(vc, animated: true, completion: nil)
                    }
                }
            ])
        )
    }
    
    // Table
    
    private func createTableFooter() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 50))
        footer.clipsToBounds = true
        
        let button = UIButton(frame: footer.bounds)
        footer.addSubview(button)
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(didTapLogOut), for: .touchUpInside)
        
        tableView.tableFooterView = footer
    }
    
    @objc func didTapLogOut() {
        let actionSheet = UIAlertController(title: "Log Out",
                                            message: "Are you sure you want to log out?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            AuthManager.shared.logOut(completion: { success in
                if success {
                    DispatchQueue.main.async {
                        let vc = LoginViewController()
                        let navVC = UINavigationController(rootViewController: vc)
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true)
                    }
                }
                else {
                    //error occured
                    fatalError("Could not log out user")
                }
            })
        }))
        
        actionSheet.popoverPresentationController?.sourceView = tableView
        actionSheet.popoverPresentationController?.sourceRect = tableView.bounds
        present(actionSheet, animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        cell.imageView?.image = model.image
        cell.imageView?.tintColor = model.color
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}
