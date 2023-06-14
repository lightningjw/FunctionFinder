//
//  NotificationFollowEventTableViewCell.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/4/23.
//

import UIKit

protocol NotificationFollowEventTableViewCellDelegate: AnyObject {
    func notificationFollowEventTableViewCell (_ cell: NotificationFollowEventTableViewCell,
                                               didTapButton isFollowing : Bool,
                                               viewModel: FollowNotificationCellViewModel)
}

class NotificationFollowEventTableViewCell: UITableViewCell {
    static let identifier = "NotificationFollowEventTableViewCell"
    
    weak var delegate: NotificationFollowEventTableViewCellDelegate?
    
    private var viewModel: FollowNotificationCellViewModel?
    
    private var isFollowing = false
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let followButton = FollowButton()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(profileImageView)
        contentView.addSubview(label)
        contentView.addSubview(followButton)
        contentView.addSubview(dateLabel)
        selectionStyle = .none
        followButton.addTarget(self,
                               action: #selector(didTapFollowButton),
                               for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapFollowButton() {
        guard let vm = viewModel
        else {
            return
        }
        delegate?.notificationFollowEventTableViewCell(self,
                                                       didTapButton: !isFollowing,
                                                       viewModel: vm)
        isFollowing = !isFollowing
        
        followButton.configure(for: isFollowing ? .unfollow : .follow)
    }
    
    public func configure(with viewModel: FollowNotificationCellViewModel) {
        self.viewModel = viewModel
        label.text = viewModel.username + " started following you."
        profileImageView.sd_setImage(with: viewModel.profilePictureUrl, completed: nil)
        isFollowing = viewModel.isCurrentUserFollowing
        dateLabel.text = viewModel.date
        
        followButton.configure(for: isFollowing ? .unfollow : .follow)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        followButton.setTitle(nil, for: .normal)
        followButton.backgroundColor = nil
        followButton.layer.borderWidth = 0
        label.text = nil
        profileImageView.image = nil
        dateLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height/1.5
        profileImageView.frame = CGRect(
            x: 10,
            y: (contentView.height-imageSize)/2,
            width: imageSize,
            height: imageSize
        )
        profileImageView.layer.cornerRadius = imageSize/2
        
        followButton.sizeToFit()
        let buttonWidth: CGFloat = max(followButton.width, 75)
        followButton.frame = CGRect(
            x: contentView.width - buttonWidth - 24,
            y: (contentView.height - followButton.height)/2,
            width: buttonWidth + 14,
            height: followButton.height
        )
        
        let labelSize = label.sizeThatFits(CGSize(
            width: contentView.width - profileImageView.width - buttonWidth - 44,
            height: contentView.height)
        )
        dateLabel.sizeToFit()
        
        label.frame = CGRect(
            x: profileImageView.right + 10,
            y: 0,
            width: labelSize.width,
            height: contentView.height - dateLabel.height - 2
        )
        
        dateLabel.frame = CGRect(
            x: profileImageView.right + 10,
            y: contentView.height - dateLabel.height - 2,
            width: dateLabel.width,
            height: dateLabel.height
        )
    }
}
