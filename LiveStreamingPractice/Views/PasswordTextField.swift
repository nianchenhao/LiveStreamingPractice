//
//  PasswordTextField.swift
//  LiveStreamingPractice
//
//  Created by Class on 2022/4/11.
//

import UIKit

class PasswordTextField: UITextField {
    
    @objc func eyeButtonTap(button: UIButton) {
        button.isSelected.toggle()
        isSecureTextEntry = button.isSelected
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isSecureTextEntry = true
        rightViewMode = .always
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
        button.isSelected = true
        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .selected)
        button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        rightView = button
        button.addTarget(self, action: #selector(eyeButtonTap(button:)), for: .touchUpInside)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        CGRect(x: bounds.width - 10 - 34, y: 0, width: 34, height: 34)
    }
    
}
