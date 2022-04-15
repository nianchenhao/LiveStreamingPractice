//
//  CircularCheckbox.swift
//  LiveStreamingPractice
//
//  Created by Class on 2022/4/7.
//

import UIKit

final class CircularCheckbox: UIView {
    
    private var isChecked = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.label.cgColor
        layer.cornerRadius = frame.size.width / 2.0
        backgroundColor = .systemBackground
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    func toggle() {
        self.isChecked = !isChecked
        
        if self.isChecked {
            backgroundColor = .systemBlue
        } else {
            backgroundColor = .systemBackground
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = UIColor.label.cgColor
    }
    
    
}
