//
//  StreamerInfoVC.swift
//  LiveStreamingPractice
//
//  Created by Robert_Nian on 2022/4/28.
//

import UIKit

class StreamerInfoVC: UIViewController {
    
    @IBOutlet weak var streamerInfoView: UIView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var streamerAvatarImage: UIImageView!
    @IBOutlet weak var streamerNicknameLabel: UILabel!
    @IBOutlet weak var streamerTitleLabel: UILabel!
    @IBOutlet weak var streamerTagsLabel: UILabel!
    
    
    var follow = false
    let userDefaults = UserDefaults()
    var streamerAvatar: String?
    var streamerNickname: String?
    var streamerOnlineViewers: Int?
    var streamerTitle: String?
    var streamerTags: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        streamerInfoView.layer.cornerRadius = 20
        streamerAvatarImage.layer.cornerRadius = streamerAvatarImage.frame.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkFollow()
        fetchStreamerAvatar()
        fetchStreamerNickname()
        fetchStreamerTitle()
        fetchStreamerTags()
    }
    
    public func configure(head_photo: String?, nickname: String?, online_num: Int?, stream_title: String?, tags: String?) {
        if head_photo != nil, nickname != nil, online_num != nil, stream_title != nil, tags != nil {
            self.streamerAvatar = head_photo
            self.streamerNickname = nickname
            self.streamerOnlineViewers = online_num
            self.streamerTitle = stream_title
            self.streamerTags = tags
        }
        
    }
    
    // MARK: - @IBAction
    @IBAction func quitButtonPress(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    @IBAction func followButtonPress(_ sender: UIButton) {
        if follow == false {
            follow = true
            userDefaults.setValue(follow, forKey: "streamerFollow")
            followButton.setTitle("關注中", for: .normal)
            self.view.makeToast("關注成功", position: .center)
            follow = true
        } else {
            follow = false
            userDefaults.setValue(follow, forKey: "streamerFollow")
            followButton.setTitle("關注", for: .normal)
            self.view.makeToast("取消關注", position: .center)
        }
    }
    
    // MARK: - Function
    func fetchStreamerAvatar() {
        guard let streamerAvatar = streamerAvatar else { return }
        guard let url = URL(string: streamerAvatar) else { return }
        do {
            let data = try Data(contentsOf: url)
            let image = UIImage(data: data)
            
            streamerAvatarImage.image = image
        } catch {
            print("image is error")
        }
    }
    
    func fetchStreamerNickname() {
        guard let streamerNickname = streamerNickname else { return }
        streamerNicknameLabel.text = streamerNickname
    }
    
    func fetchStreamerTitle() {
        guard let streamerTitle = streamerTitle else { return }
        streamerTitleLabel.text = streamerTitle
    }
    
    func fetchStreamerTags() {
        guard let streamerTags = streamerTags else { return }
        streamerTagsLabel.text = "#" + streamerTags
    }
    
    func checkFollow() {
        //拿看看值，沒拿到的話直接return出去
        guard
            let defaultFollow = userDefaults.value(forKey: "streamerFollow") as? Bool
        else {
            print("沒存過值")
            return
        }
        print("已存過值 為\(defaultFollow)")
        //修改follow
        follow = defaultFollow
        
        //如果為true 修改按鈕的title
        guard follow == true else{
            return
        }
        followButton.setTitle("關注中", for: .normal)
    }
    
}
