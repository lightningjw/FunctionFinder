//
//  SignInHeaderView.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/6/23.
//

import UIKit

class LoginHeaderView: UIView {
    
    private var gradientLayer: CALayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        createGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func createGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemGreen.cgColor]
        layer.addSublayer(gradientLayer)
        self.gradientLayer = gradientLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = layer.bounds
    }

}
