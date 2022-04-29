//
//  StreamerInfoVC.swift
//  LiveStreamingPractice
//
//  Created by Robert_Nian on 2022/4/28.
//

import UIKit
import Firebase

protocol StreamerInfoVCDelegate: AnyObject {
    func followChat()
}

class StreamerInfoVC: UIViewController {
    
    @IBOutlet weak var streamerInfoView: UIView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var streamerAvatarImage: UIImageView!
    @IBOutlet weak var streamerNicknameLabel: UILabel!
    @IBOutlet weak var streamerTitleLabel: UILabel!
    @IBOutlet weak var streamerTagsLabel: UILabel!
    
    weak var delegate: StreamerInfoVCDelegate!
    var follow = false
    let userDefaults = UserDefaults()
    var streamerAvatar: String?
    var streamerNickname: String?
    var streamerOnlineViewers: Int?
    var streamerTitle: String?
    var streamerTags: [String]?
    var key = "訪客"
    var handle: AuthStateDidChangeListenerHandle?
    var loginStatus = false
    
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
        
        handle = Auth.auth().addStateDidChangeListener({ [self] auth, user in
            
            //檢查是否登入狀態
            guard
                user != nil,
                Auth.auth().currentUser != nil,
                let user = Auth.auth().currentUser
            else{
                return
            }
            self.loginStatus = true
            let email = user.email
            let emailStr = String(email!)
            let reference = Firestore.firestore().collection("Users")
            reference.document(emailStr).getDocument { snapshot, error in
                
                guard
                    snapshot != nil,
                    let snapshotData = snapshot!.data()!["nickName"],
                    let nameStr = snapshotData as? String
                else{
                    return
                }
                
                self.key = "\(nameStr)"
                print("我的暱稱是\(self.key)")
                
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    public func configure(head_photo: String?, nickname: String?, online_num: Int?, stream_title: String?, tags: [String]?) {
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
        guard loginStatus == true else { return showAlert(title: "系統訊息", message: "請先註冊會員後才能關注主播喔!") }
        if follow == false {
            follow = true
            userDefaults.setValue(follow, forKey: "streamerFollow")
            followButton.setTitle("關注中", for: .normal)
            self.view.makeToast("關注成功", position: .center)
            delegate?.followChat()
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
//        streamerTagsLabel.text = "#" + streamerTags
        if streamerTags.count > 1 {
            streamerTagsLabel.text = "#\(streamerTags[0])  #\(streamerTags[1])"
        } else if streamerTags.count == 1 {
            streamerTagsLabel.text = "#\(streamerTags[0])"
        } else {
            streamerTagsLabel.text = ""
        }
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
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("OkButton", comment: "確定"), style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}


