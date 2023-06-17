//
//  StoryCollectionViewCell.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/17/23.
//

import UIKit

class StoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "StoryCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let label: UILabel = {
        let UILabel = UILabel()
        UILabel.textAlignment = .center
        return UILabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.sizeToFit()
        label.frame = CGRect(x: 0, y: contentView.height - label.height, width: contentView.width, height: label.height)
        
        let imageSize: CGFloat = contentView.height - label.height - 7
        imageView.layer.cornerRadius = imageSize/2
        imageView.frame = CGRect(x: (contentView.width - imageSize), y: 2, width: imageSize, height: imageSize)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        imageView.image = nil
    }
    
    func configure(with story: Story) {
        label.text = story.username
        imageView.image = story.image
    }
}
