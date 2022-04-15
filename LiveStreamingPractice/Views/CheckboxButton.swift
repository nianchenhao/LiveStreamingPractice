//
//  CheckboxButton.swift
//  LiveStreamingPractice
//
//  Created by Class on 2022/4/7.
//

import UIKit

class CheckboxButton: UIView {
    
    var isChecked = false
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        imageView.image = UIImage(systemName: "checkmark")
        return imageView
    }()
    
    let boxView: UIView = {
       let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.label.cgColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(boxView)
        addSubview(imageView)
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        boxView.frame = CGRect(x: 5, y: 5, width: frame.size.width - 8, height: frame.size.width - 8)
        imageView.frame = bounds
    }
    
    public func toggle() {
        self.isChecked = !isChecked
        
        imageView.isHidden = !isChecked
    }
}
