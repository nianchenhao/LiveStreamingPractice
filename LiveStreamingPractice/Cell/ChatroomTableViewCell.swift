//
//  ChatroomTableViewCell.swift
//  LiveStreamingPractice
//
//  Created by Class on 2022/4/13.
//

import UIKit

class ChatroomTableViewCell: UITableViewCell {

    @IBOutlet weak var chatTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
