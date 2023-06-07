//
//  TextField.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/6/23.
//

import UIKit

class TextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        returnKeyType = .next
        leftViewMode = .always
        layer.cornerRadius = 8
        layer.borderWidth = 1.0
        backgroundColor = .secondarySystemBackground
        layer.borderColor = UIColor.secondaryLabel.cgColor
        autocapitalizationType = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

}
