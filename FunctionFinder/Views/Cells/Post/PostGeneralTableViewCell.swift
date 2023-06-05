//
//  PostGeneralTableViewCell.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/5/23.
//

import UIKit

/// Comments
class PostGeneralTableViewCell: UITableViewCell {
    
    static let identifier = "PostGeneralTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemOrange
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure() {
        // configure the cell
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
