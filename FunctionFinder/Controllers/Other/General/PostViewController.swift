//
//  PostViewController.swift
//  FunctionFinder
//
//  Created by Justin Wong on 5/26/23.
//

import UIKit

/*
 
 Section
 - Header model
 Section
 - Post Cell model
 Section
 - Action Buttons Cell model
 Section
 - n Number of general models for comments
 
 */

/// States of a rendered cell
enum PostRenderType {
    case header(provider: User)
    case primaryContent(provider: UserPost) // post
    case actions(provider: String) // like, comment, share
    case comments(comments: [PostComment])
}

/// Model of rendered Post
struct PostRenderViewModel {
    let renderType: PostRenderType
}

class PostViewController: UIViewController {
    
    let post: Post
    
//    private let model: UserPost?
//
//    private var renderModels = [PostRenderViewModel]()
//
//    private let tableView: UITableView = {
//        let tableView = UITableView()
//
//        // Register cells
//        tableView.register(PostTableViewCell.self,
//                           forCellReuseIdentifier: PostTableViewCell.identifier)
//        tableView.register(PostHeaderTableViewCell.self,
//                           forCellReuseIdentifier: PostHeaderTableViewCell.identifier)
//        tableView.register(PostActionsTableViewCell.self,
//                           forCellReuseIdentifier: PostActionsTableViewCell.identifier)
//        tableView.register(PostGeneralTableViewCell.self,
//                           forCellReuseIdentifier: PostGeneralTableViewCell.identifier)
//
//        return tableView
//    }()
    
    // MARK: - Init
    
//    init(model: UserPost?) {
//        self.model = model
//        super.init(nibName: nil, bundle: nil)
//        configureModels()
//    }
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
//        configureModels()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
//    private func configureModels() {
//        guard let userPostModel = self.model else {
//            return
//        }
//        // Header
//        renderModels.append(PostRenderViewModel(renderType: .header(provider: userPostModel.owner)))
//
//        // Post
//        renderModels.append(PostRenderViewModel(renderType: .primaryContent(provider: userPostModel)))
//
//        // Actions
//        renderModels.append(PostRenderViewModel(renderType: .actions(provider: "")))
//
//        // 4 Comments
//        var comments = [PostComment]()
//        for x in 0..<4 {
//            comments.append(
//                PostComment(
//                    identifier: "123_\(x)",
//                    username: "@dave",
//                    text: "Great post!",
//                    createdDate: Date(),
//                    likes: []
//                )
//            )
//        }
//        renderModels.append(PostRenderViewModel(renderType: .comments(comments: comments)))
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Post"
//        view.addSubview(tableView)
//        tableView.delegate = self
//        tableView.dataSource = self
        view.backgroundColor = .systemBackground
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        tableView.frame = view.bounds
//    }

}

//extension PostViewController: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return renderModels.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch renderModels[section].renderType {
//            case .actions(_): return 1
//            case .comments(let comments): return comments.count > 4 ? 4 : comments.count
//            case .primaryContent(_): return 1
//            case .header(_): return 1
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let model  = renderModels[indexPath.section]
//
//        switch model.renderType {
//            case .actions(let actions):
//                let cell = tableView.dequeueReusableCell(withIdentifier: PostActionsTableViewCell.identifier,
//                                                         for: indexPath) as! PostActionsTableViewCell
//                return cell
//            case .comments(let comments):
//                let cell = tableView.dequeueReusableCell(withIdentifier: PostGeneralTableViewCell.identifier,
//                                                         for: indexPath) as! PostGeneralTableViewCell
//                return cell
//            case .primaryContent(let post):
//                let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier,
//                                                         for: indexPath) as! PostTableViewCell
//                return cell
//            case .header(let user):
//                let cell = tableView.dequeueReusableCell(withIdentifier: PostHeaderTableViewCell.identifier,
//                                                         for: indexPath) as! PostHeaderTableViewCell
//                return cell
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let model = renderModels[indexPath.section]
//
//        switch model.renderType {
//            case .actions(let actions): return 60
//            case .comments(let comments): return 50
//            case .primaryContent(let post): return tableView.width
//            case .header(let user): return 70
//        }
//    }
//}
