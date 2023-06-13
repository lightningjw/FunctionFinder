//
//  NotificationCommentEventTableViewCell.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/12/23.
//

import UIKit

import SDWebImage
import UIKit

protocol NotificationCommentEventTableViewCellDelegate: AnyObject {
    func notificationCommentEventTableViewCell(_ cell: NotificationCommentEventTableViewCell,
                                               didTapPostWith viewModel: CommentNotificationCellViewModel)
}

class NotificationCommentEventTableViewCell: UITableViewCell {
    static let identifier = "NotificationCommentEventTableViewCell"
    
    private var viewModel: CommentNotificationCellViewModel?
    
    weak var delegate: NotificationCommentEventTableViewCellDelegate?
        
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(profileImageView)
        contentView.addSubview(label)
        contentView.addSubview(postImageView)
        contentView.addSubview(dateLabel)
        selectionStyle = .none
        postImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPost))
        postImageView.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapPost() {
        guard let vm = viewModel
        else {
            return
        }
        delegate?.notificationCommentEventTableViewCell(self,
                                                        didTapPostWith: vm)
    }
    
    public func configure(with viewModel: CommentNotificationCellViewModel) {
        self.viewModel = viewModel
        label.text = viewModel.username + " commented on your post."
        profileImageView.sd_setImage(
            with: viewModel.profilePictureUrl,
            completed: nil
        )
        postImageView.sd_setImage(with: viewModel.postUrl, completed: nil)
        dateLabel.text = viewModel.date
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        profileImageView.image = nil
        postImageView.image = nil
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
        
        let postSize: CGFloat = contentView.height - 6
        postImageView.frame = CGRect(
            x: contentView.width - postSize - 10,
            y: 3,
            width: postSize,
            height: postSize
        )
        
        let labelSize = label.sizeThatFits(
            CGSize(
                width: contentView.width - profileImageView.right - 25 - postSize,
                height: contentView.height
            )
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
