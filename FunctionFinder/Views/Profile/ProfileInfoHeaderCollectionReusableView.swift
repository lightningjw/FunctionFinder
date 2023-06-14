//
//  ProfileInfoHeaderCollectionReusableView.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/2/23.
//

import UIKit

protocol ProfileInfoHeaderCollectionReusableViewDelegate: AnyObject {
    func profileInfoHeaderCollectionReusableViewDidTapProfilePicture(_ header: ProfileInfoHeaderCollectionReusableView)
}

final class ProfileInfoHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "ProfileInfoHeaderCollectionReusableView"
    
    private let profilePhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    public weak var delegate: ProfileInfoHeaderCollectionReusableViewDelegate?
    
    public let countContainerView = ProfileInfoHeaderCountView()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.text = "This is the first account"
        label.numberOfLines = 0 // line wrap
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        backgroundColor = .systemBackground
        clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        profilePhotoImageView.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func addSubviews() {
        addSubview(profilePhotoImageView)
        addSubview(countContainerView)
        addSubview(bioLabel)
    }
    
    @objc func didTapImage() {
        delegate?.profileInfoHeaderCollectionReusableViewDidTapProfilePicture(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let profilePhotoSize = width/3.5
        profilePhotoImageView.frame = CGRect(
            x: 5,
            y: 5,
            width: profilePhotoSize,
            height: profilePhotoSize
        )
        profilePhotoImageView.layer.cornerRadius = profilePhotoSize/2
        
        countContainerView.frame = CGRect(
            x: profilePhotoImageView.right + 5,
            y: 3,
            width: width - profilePhotoImageView.right - 10,
            height: profilePhotoSize
        )
        
        let bioSize = bioLabel.sizeThatFits(
            bounds.size
        )
        bioLabel.frame = CGRect(
            x: 5,
            y: profilePhotoImageView.bottom + 10,
            width: width - 10,
            height: bioSize.height + 50
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePhotoImageView.image = nil
        bioLabel.text = nil
    }
    
    public func configure(with viewModel: ProfileInfoHeaderViewModel) {
        profilePhotoImageView.sd_setImage(with: viewModel.profilePictureUrl, completed: nil)
        var text = ""
        if let name = viewModel.name {
            text = name + "\n"
        }
        text += viewModel.bio ?? "Welcome to my profile!"
        bioLabel.text = text
        // Container
        let containerViewModel = ProfileInfoHeaderCountViewViewModel(
            followerCount: viewModel.followerCount,
            followingCount: viewModel.followingCount,
            postCount: viewModel.postCount,
            actionType: viewModel.buttonType
        )
        countContainerView.configure(with: containerViewModel)
    }
}
