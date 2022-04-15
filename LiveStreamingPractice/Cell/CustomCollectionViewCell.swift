//
//  CustomCollectionViewCell.swift
//  LiveStreamingPractice
//
//  Created by Class on 2022/3/30.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var streamTitleLabel: UILabel!
    @IBOutlet weak var onlineNumLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage(named: "paopao.png")
    }
}
