//
//  CustomMarkerView.swift
//  FunctionFinder
//
//  Created by Justin Wong on 5/31/23.
//

import Foundation
import UIKit

class CustomMarkerView: UIView {
    var img: URL!
    var borderColor: UIColor!
    
    init(frame: CGRect, image: URL, borderColor: UIColor, tag: Int){
        super.init(frame: frame)
        self.img = image
        self.borderColor = borderColor
        self.tag = tag
        
        setupViews()
    }
    
    func setupViews() {
        let imgView = UIImageView()
        imgView.sd_setImage(with: img, completed: nil)
        imgView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        imgView.layer.cornerRadius = 25
        imgView.layer.borderColor = borderColor?.cgColor
        imgView.layer.borderWidth = 4
        imgView.clipsToBounds = true
        let lbl = UILabel(frame: CGRect(x: 0, y: 45, width: 50, height: 10))
        lbl.text = "v"
        lbl.font = UIFont.systemFont(ofSize: 24)
        lbl.textColor = borderColor
        lbl.textAlignment = .center
        
        self.addSubview(imgView)
        self.addSubview(lbl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
