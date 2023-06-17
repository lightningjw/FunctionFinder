//
//  CommentCollectionViewCell.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/15/23.
//

import UIKit

class CommentCollectionViewCell: UICollectionViewCell {
    static let identifier = "CommentCollectionViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
//        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.addSubview(label)
        contentView.backgroundColor = .systemBackground
        // Add constraints
//        NSLayoutConstraint.activate([
//            label.topAnchor.constraint(equalTo: contentView.topAnchor),
//            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
//        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        label.frame = CGRect(x: 5, y: 0, width: contentView.width - 10, height: contentView.height)
        let size = label.sizeThatFits(CGSize(width: contentView.bounds.size.width - 12,
                                             height: contentView.bounds.size.height))
        label.frame = CGRect(x: 12, y: 3, width: size.width, height: size.height)
    }
    
    func configure(with model: [Comment]) {
        if (model.isEmpty) {
            return
        }
        var comment: Comment
        comment = model[0]
        label.text = "\(comment.username): \(comment.comment)"
        for i in 1...model.count - 1 {
            comment = model[i]
            label.text = label.text! + "\n\n\(comment.username): \(comment.comment)"
        }
    }
}
