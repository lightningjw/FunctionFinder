//
//  NotificationsViewController.swift
//  FunctionFinder
//
//  Created by Justin Wong on 5/26/23.
//

import UIKit

final class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let noActivityLabel: UILabel = {
        let label = UILabel()
        label.text = "No Notifications"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private var viewModels: [NotificationCellType] = []
    private var models: [AppNotification] = []
    
    // MARK: - Lifecycle
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.isHidden = true
        tableView.register(
            NotificationLikeEventTableViewCell.self,
            forCellReuseIdentifier: NotificationLikeEventTableViewCell.identifier
        )
        tableView.register(
            NotificationFollowEventTableViewCell.self,
            forCellReuseIdentifier: NotificationFollowEventTableViewCell.identifier
        )
        tableView.register(
            NotificationCommentEventTableViewCell.self,
            forCellReuseIdentifier: NotificationCommentEventTableViewCell.identifier
        )
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(noActivityLabel)
        fetchNotifications()
    }
    
    private func fetchNotifications() {
        NotificationsManager.shared.getNotifications { [weak self] models in
            DispatchQueue.main.async {
                self?.models = models
                self?.createViewModels()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noActivityLabel.sizeToFit()
        noActivityLabel.center = view.center
    }
    
    private func createViewModels() {
        models.forEach { model in
            guard let type = NotificationsManager.AppType(rawValue: model.notificationType)
            else {
                return
            }
            let username = model.username
            guard let profilePictureUrl = URL(string: model.profilePictureUrl)
            else {
                return
            }
            
            // Derive
            
            switch type {
            case .like:
                guard let postUrl = URL(string: model.postUrl ?? "")
                else {
                    return
                }
                viewModels.append(
                    .like(
                        viewModel: LikeNotificationCellViewModel(
                            username: username,
                            profilePictureUrl: profilePictureUrl,
                            postUrl: postUrl,
                            date: model.dateString
                        )
                    )
                )
            case .comment:
                guard let postUrl = URL(string: model.postUrl ?? "")
                else {
                    return
                }
                viewModels.append(
                    .comment(
                        viewModel: CommentNotificationCellViewModel(
                            username: username,
                            profilePictureUrl: profilePictureUrl,
                            postUrl: postUrl,
                            date: model.dateString
                        )
                    )
                )
            case .follow:
                guard let isFollowing = model.isFollowing
                else {
                    return
                }
                viewModels.append(
                    .follow(
                        viewModel: FollowNotificationCellViewModel(
                            username: username,
                            profilePictureUrl: profilePictureUrl,
                            isCurrentUserFollowing: isFollowing,
                            date: model.dateString
                        )
                    )
                )
            }
        }
        
        if viewModels.isEmpty {
            noActivityLabel.isHidden = false
            tableView.isHidden = true
        }
        else {
            noActivityLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    /// Creates mock data to test with
    private func mockData() {
        tableView.isHidden = false
        guard let postUrl = URL(string: "https://iosacademy.io/assets/images/courses/swiftui.png")
        else{
            return
        }
        guard let iconUrl = URL(string: "https://iosacademy.io/assets/images/brand/icon.jpg")
        else{
            return
        }
        
        viewModels = [
            .like(
                viewModel: LikeNotificationCellViewModel(
                    username: "kyliejenner",
                    profilePictureUrl: iconUrl,
                    postUrl: postUrl,
                    date: "March 12"
                )
            ),
            .comment(
                viewModel: CommentNotificationCellViewModel(
                    username: "jeffbezos",
                    profilePictureUrl: iconUrl,
                    postUrl: postUrl,
                    date: "March 12"
                )
            ),
            .follow(
                viewModel: FollowNotificationCellViewModel(
                    username: "zuck21",
                    profilePictureUrl: iconUrl,
                    isCurrentUserFollowing: true,
                    date: "March 12"
                )
            )
        ]
        
        tableView.reloadData()
    }
    
    // MARK: - Table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = viewModels[indexPath.row]
        switch cellType {
        case.like(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationLikeEventTableViewCell.identifier,
                for: indexPath
            ) as? NotificationLikeEventTableViewCell
            else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        case .follow(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationFollowEventTableViewCell.identifier,
                for: indexPath
            ) as? NotificationFollowEventTableViewCell
            else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        case .comment(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationCommentEventTableViewCell.identifier,
                for: indexPath
            ) as? NotificationCommentEventTableViewCell
            else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellType = viewModels[indexPath.row]
        let username: String
        switch cellType {
        case .follow(let viewModel):
            username = viewModel.username
        case .like(let viewModel):
            username = viewModel.username
        case .comment(let viewModel):
            username = viewModel.username
        }
                
        DatabaseManager.shared.findUser(username: username) { [weak self] user in
            guard let user = user
            else {
                return
            }
            
            DispatchQueue.main.async {
                let vc = ProfileViewController(user: user)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

}

// MARK: - Actions

extension NotificationsViewController: NotificationLikeEventTableViewCellDelegate, NotificationFollowEventTableViewCellDelegate, NotificationCommentEventTableViewCellDelegate {
    func notificationLikeEventTableViewCell(_ cell: NotificationLikeEventTableViewCell,
                                            didTapPostWith viewModel: LikeNotificationCellViewModel) {
        guard let index = viewModels.firstIndex(where: {
            switch $0 {
            case .comment, .follow:
                return false
            case .like(let current):
                return current == viewModel
            }
        })
        else {
            return
        }
        
        openPost(with: index, username: viewModel.username)
        
        // Find post by id from particular user
        
    }
    
    func notificationFollowEventTableViewCell(_ cell: NotificationFollowEventTableViewCell,
                                              didTapButton isFollowing: Bool,
                                              viewModel: FollowNotificationCellViewModel) {
        let username = viewModel.username
        DatabaseManager.shared.updateRelationship(
            state: isFollowing ? .follow : .unfollow,
            for: username)
        { [weak self] success in
            if !success {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Whoops",
                                                  message: "Unable to perform action.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss",
                                                  style: .cancel,
                                                  handler: nil))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    func notificationCommentEventTableViewCell(_ cell: NotificationCommentEventTableViewCell,
                                               didTapPostWith viewModel: CommentNotificationCellViewModel) {
        guard let index = viewModels.firstIndex(where: {
            switch $0 {
            case .like, .follow:
                return false
            case .comment(let current):
                return current == viewModel
            }
        })
        else {
            return
        }
        
        openPost(with: index, username: viewModel.username)
    }
    
    func openPost(with index: Int, username: String) {
        guard index < models.count
        else {
            return
        }
        
        let model = models[index]
        let username = username
        guard let postID = model.postId
        else {
            return
        }
        
        // Find post by id from target user
        DatabaseManager.shared.getPost(
            with: postID,
            from: username) { [weak self] post in
                DispatchQueue.main.async {
                    guard let post = post
                    else {
                        let alert = UIAlertController(
                            title: "Oops",
                            message: "We are unable to open this post.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                        self?.present(alert, animated: true)
                        return
                    }
                    
                    let vc = PostViewController(post: post, owner: username)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
    }
}
