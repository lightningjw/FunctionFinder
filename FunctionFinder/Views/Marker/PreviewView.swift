//
//  PreviewView.swift
//  FunctionFinder
//
//  Created by Justin Wong on 5/31/23.
//

import Foundation
import UIKit

class PreviewView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        setupViews()
    }
    
    func setData(title: String, img: URL, time: String) {
        lblTitle.text = title
        imgView.sd_setImage(with: img, completed: nil)
        lblTime.text = time
    }
    
    func setupViews() {
        addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        containerView.addSubview(lblTitle)
        lblTitle.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        lblTitle.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        lblTitle.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
        lblTitle.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        addSubview(imgView)
        imgView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imgView.topAnchor.constraint(equalTo: lblTitle.bottomAnchor).isActive = true
        imgView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imgView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(lblTime)
        lblTime.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        lblTime.centerYAnchor.constraint(equalTo: imgView.centerYAnchor).isActive = true
        lblTime.widthAnchor.constraint(equalToConstant: 90).isActive = true
        lblTime.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let imgView: UIImageView = {
        let v = UIImageView()
        v.image = #imageLiteral(resourceName: "house")
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Name"
        lbl.font = UIFont.boldSystemFont(ofSize: 28)
        lbl.textColor = UIColor.black
        lbl.backgroundColor = UIColor.white
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let lblTime: UILabel = {
        let lbl = UILabel()
        lbl.text = "12:00"
        lbl.font = UIFont.boldSystemFont(ofSize: 32)
        lbl.textColor = UIColor.white
        lbl.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        lbl.textAlignment = .center
        lbl.layer.cornerRadius = 5
        lbl.clipsToBounds = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
