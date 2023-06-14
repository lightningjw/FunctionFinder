//
//  ProfileHeaderCountView.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/13/23.
//

import UIKit

protocol ProfileInfoHeaderCountViewDelegate: AnyObject {
    func profileInfoHeaderCountViewDidTapFollowers(_ containerView: ProfileInfoHeaderCountView)
    func profileInfoHeaderCountViewDidTapFollowing(_ containerView: ProfileInfoHeaderCountView)
    func profileInfoHeaderCountViewDidTapPosts(_ containerView: ProfileInfoHeaderCountView)
    func profileInfoHeaderCountViewDidTapEditProfile(_ containerView: ProfileInfoHeaderCountView)
    func profileInfoHeaderCountViewDidTapFollow(_ containerView: ProfileInfoHeaderCountView)
    func profileInfoHeaderCountViewDidTapUnfollow(_ containerView: ProfileInfoHeaderCountView)
}

class ProfileInfoHeaderCountView: UIView {
    
    weak var delegate: ProfileInfoHeaderCountViewDelegate?
    
    private var action = ProfileButtonType.edit
    
    // Count Buttons
    
    private let followerCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()
    
    private let followingCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()
    
    private let postCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()
    
    private let actionButton = FollowButton()
    
    private var isFollowing = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(followerCountButton)
        addSubview(followingCountButton)
        addSubview(postCountButton)
        addSubview(actionButton)
        addActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func addActions() {
        followerCountButton.addTarget(self, action:#selector(didTapFollowers), for: .touchUpInside)
        followingCountButton.addTarget(self, action: #selector(didTapFollowing), for: .touchUpInside)
        postCountButton.addTarget(self, action: #selector(didTapPosts), for: .touchUpInside)
        actionButton.addTarget(self, action:#selector(didTapActionButton), for: .touchUpInside)
    }
    
    @objc private func didTapFollowers() {
        delegate?.profileInfoHeaderCountViewDidTapFollowers(self)
    }

    @objc private func didTapFollowing() {
        delegate?.profileInfoHeaderCountViewDidTapFollowing(self)
    }

    @objc private func didTapPosts() {
        delegate?.profileInfoHeaderCountViewDidTapPosts(self)
    }
    
    @objc private func didTapActionButton() {
        switch action {
        case .edit:
            delegate?.profileInfoHeaderCountViewDidTapEditProfile(self)
        case .follow:
            if self.isFollowing {
                // Unfollow
                delegate?.profileInfoHeaderCountViewDidTapUnfollow(self)
            }
            else {
                // Follow
                delegate?.profileInfoHeaderCountViewDidTapFollow(self)
            }
            self.isFollowing = !isFollowing
            actionButton.configure(for: isFollowing ? .unfollow : .follow)
        }
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonWidth: CGFloat = (width - 15)/3
        followerCountButton.frame = CGRect(
            x: 5,
            y: 5,
            width: buttonWidth,
            height: height/2
        )
        followingCountButton.frame = CGRect(
            x: followerCountButton.right + 5,
            y: 5,
            width: buttonWidth,
            height: height/2
        )
        postCountButton.frame = CGRect(
            x: followingCountButton.right + 5,
            y: 5,
            width: buttonWidth,
            height: height/2
        )
        actionButton.frame = CGRect(
            x: 5,
            y: height - 42,
            width: width - 10,
            height: 40
        )
    }

    func configure(with viewModel: ProfileInfoHeaderCountViewViewModel) {
        followerCountButton.setTitle("\(viewModel.followerCount)\nFollowers", for: .normal)
        followingCountButton.setTitle("\(viewModel.followingCount)\nFollowing", for: .normal)
        postCountButton.setTitle("\(viewModel.postCount)\nPosts", for: .normal)
        
        self.action = viewModel.actionType
                
        switch viewModel.actionType {
        case .edit:
            actionButton.backgroundColor = .systemBackground
            actionButton.setTitle("Edit Profile", for: .normal)
            actionButton.setTitleColor(.label, for: .normal)
            actionButton.layer.borderWidth = 0.5
            actionButton.layer.borderColor = UIColor.tertiaryLabel.cgColor

        case .follow(let isFollowing):
            self.isFollowing = isFollowing
            actionButton.configure(for: isFollowing ? .unfollow : .follow)
        }
    }
}
