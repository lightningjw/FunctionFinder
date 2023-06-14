//
//  PostViewController.swift
//  FunctionFinder
//
//  Created by Justin Wong on 5/26/23.
//

import UIKit

/// Profile view controller
final class ProfileViewController: UIViewController {
        
    private let user: User
    
    private var isCurrentUser: Bool {
        return user.username.lowercased() == UserDefaults.standard.string(forKey: "username")?.lowercased() ?? ""
    }
    
    private var collectionView: UICollectionView?
    
    private var headerViewModel: ProfileInfoHeaderViewModel?
    
    private var posts: [Post] = []
    
    // MARK: - Init
    
    init (user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = user.username.uppercased()
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureCollectionView()
        fetchProfileInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    private func fetchProfileInfo() {
        let username = user.username
        
        let group = DispatchGroup()
        
        // Fetch Posts
        group.enter()
        DatabaseManager.shared.posts(for: username) { [weak self] result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let posts):
                self?.posts = posts
            case .failure:
                break
            }
        }
        
        // Fetch Profile Header Info
        
        var profilePictureUrl: URL?
        var buttonType: ProfileButtonType = .edit
        var followers = 0
        var following = 0
        var posts = 0
        var name: String?
        var bio: String?
        
        // Counts (3)
        group.enter()
        DatabaseManager.shared.getUserCounts(username: user.username) { result in
            defer {
                group.leave()
            }
            posts = result.posts
            followers = result.followers
            following = result.following
        }
        
        // Bio, name
        DatabaseManager.shared.getUserInfo(username: user.username) { userInfo in
            name = userInfo?.name
            bio = userInfo?.bio
        }
        
        // Profile picture url
        group.enter()
        StorageManager.shared.profilePictureURL(for: user.username) { url in
            defer{
                group.leave()
            }
            profilePictureUrl = url
        }
        
        // If profile is not for current user
        if !isCurrentUser {
            // Get follow state
            group.enter()
            DatabaseManager.shared.isFollowing(targetUsername: user.username) { isFollowing in
                defer {
                    group.leave()
                }
                buttonType = .follow(isFollowing: isFollowing)
            }
        }
        
        group.notify(queue: .main) {
            self.headerViewModel = ProfileInfoHeaderViewModel(
                profilePictureUrl: profilePictureUrl,
                followerCount: followers,
                followingCount: following,
                postCount: posts,
                buttonType: buttonType,
                name: name,
                bio: bio
            )
            self.collectionView?.reloadData()
        }
    }
    
    private func configureNavigationBar() {
        if isCurrentUser {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(didTapSettingsButton))
        }
    }
    
    @objc private func didTapSettingsButton() {
        let vc = SettingsViewController()
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier,
                                                      for: indexPath) as? PhotoCollectionViewCell
        else {
            fatalError()
        }
        cell.configure(with: URL(string: posts[indexPath.row].postUrlString))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ProfileInfoHeaderCollectionReusableView.identifier,
                for: indexPath
              ) as? ProfileInfoHeaderCollectionReusableView
        else {
            return UICollectionReusableView()
        }
        if let viewModel = headerViewModel {
            headerView.configure(with: viewModel)
            headerView.countContainerView.delegate = self
        }
        headerView.delegate = self
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let post = posts[indexPath.row]
        let vc = PostViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileViewController: ProfileInfoHeaderCollectionReusableViewDelegate {
    func profileInfoHeaderCollectionReusableViewDidTapProfilePicture(_ header: ProfileInfoHeaderCollectionReusableView) {
        
        guard isCurrentUser
        else {
            return
        }
        
        let sheet = UIAlertController(
            title: "Change Picture",
            message: "Update your photo to reflect your best self",
            preferredStyle: .actionSheet
        )
        
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
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        StorageManager.shared.uploadProfilePicture(
            username: user.username,
            data: image.pngData()) { [weak self] success in
                if success {
                    self?.headerViewModel = nil
                    self?.posts = []
                    self?.fetchProfileInfo()
                }
            }
    }
}

extension ProfileViewController: ProfileInfoHeaderCountViewDelegate {
    func profileInfoHeaderCountViewDidTapFollowers(_ containerView: ProfileInfoHeaderCountView) {
        let vc = ListViewController(type: .followers(user: user))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func profileInfoHeaderCountViewDidTapFollowing(_ containerView: ProfileInfoHeaderCountView) {
        let vc = ListViewController(type: .following(user: user))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func profileInfoHeaderCountViewDidTapPosts(_ containerView: ProfileInfoHeaderCountView) {
        guard posts.count >= 18
        else {
            return
        }
        collectionView?.setContentOffset(CGPoint(x: 0, y: view.width * 0.4),
                                         animated: true)
    }
    
    func profileInfoHeaderCountViewDidTapEditProfile(_ containerView: ProfileInfoHeaderCountView) {
        let vc = EditProfileViewController()
        vc.completion = { [weak self] in
            self?.headerViewModel = nil
            self?.fetchProfileInfo()
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    func profileInfoHeaderCountViewDidTapFollow(_ containerView: ProfileInfoHeaderCountView) {
        DatabaseManager.shared.updateRelationship(
            state: .follow,
            for: user.username){ [weak self] success in
                if !success {
                    print("failed to follow")
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                }
            }
    }
    
    func profileInfoHeaderCountViewDidTapUnfollow(_ containerView: ProfileInfoHeaderCountView) {
        DatabaseManager.shared.updateRelationship(
            state: .unfollow,
            for: user.username){ [weak self] success in
                if !success {
                    print("failed to follow")
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                }
            }
    }
}

extension ProfileViewController: ProfileTabsCollectionReusableViewDelegate {
    func didTapGridButtonTab() {
        // Reload collection view with data
        
    }
    
    func didTapTaggedButtonTab() {
        // Reload collection view with data
        
    }
}

extension ProfileViewController {
    func configureCollectionView() {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: {index, _ -> NSCollectionLayoutSection? in
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                
                item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(1/3)
                    ),
                    subitem: item,
                    count: 3
                )
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [
                    NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalWidth(2/3)
                        ),
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .top)
                ]
                
                return section
            })
        )
        collectionView.register(PhotoCollectionViewCell.self,
                                forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView.register(ProfileInfoHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ProfileInfoHeaderCollectionReusableView.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        self.collectionView = collectionView
    }
}
