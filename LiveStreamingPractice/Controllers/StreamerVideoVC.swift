//
//  ViewController.swift
//  LiveStreamingPractice
//
//  Created by Class on 2022/3/28.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Lottie
import Toast
import MarqueeLabel

class StreamerVideoVC: UIViewController, URLSessionWebSocketDelegate {
    
    //    static let shared = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StreamerVideoVC") as! StreamerVideoVC
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var chatViewLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var streamerView: UIView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var sendGiftButton: UIButton!
    @IBOutlet weak var streamerAvatarButton: UIButton!
    @IBOutlet weak var streamerNicknameLabel: UILabel!
    @IBOutlet weak var streamerOnlineViewersLabel: UILabel!
    @IBOutlet var chatButton: UIButton!
    @IBOutlet var announcementLabel: MarqueeLabel!
    
    var videoPlayer: AVPlayer?
    var looper: AVPlayerLooper?
    var webSocket: URLSessionWebSocketTask?
    var chatArray = [String]()
    var userNameToChat = [String]()
    var key = NSLocalizedString("VisitorNickname", comment: "訪客")
    var handle: AuthStateDidChangeListenerHandle?
    var animationView: AnimationView?
    var follow = false
    let userDefaults = UserDefaults()
    var streamerAvatar: String?
    var streamerNickname: String?
    var streamerOnlineViewers: Int?
    var streamerTitle: String?
    var streamerTags: [String]?
    var loginStatus = false
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        announcementLabel.type = .continuous
        announcementLabel.animationCurve = .easeInOut
        announcementLabel.fadeLength = 10.0
        announcementLabel.leadingBuffer = 10.0
        announcementLabel.trailingBuffer = 20.0
        announcementLabel.layer.cornerRadius = 10
        
        chatTextField.delegate = self
        chatTextField.isHidden = true
        sendButton.isHidden = true
        
        chatButton.layer.cornerRadius = chatButton.frame.width / 2
        //        let customInputAccessoryView = CustomView()
        //        chatTextField.inputAccessoryView = customInputAccessoryView
        
        quitButton.layer.cornerRadius = quitButton.frame.width / 2
        quitButton.layer.masksToBounds = true
        sendButton.layer.cornerRadius = quitButton.frame.width / 2
        sendButton.layer.masksToBounds = true
        chatTextField.layer.cornerRadius = 15
        chatTextField.layer.masksToBounds = true
        shareButton.layer.cornerRadius = shareButton.frame.width / 2
        streamerView.layer.cornerRadius = 20
        followButton.layer.cornerRadius = followButton.frame.width / 2
        streamerAvatarButton.layer.cornerRadius = streamerAvatarButton.frame.width / 2
        streamerAvatarButton.clipsToBounds = true
        
        let placeholder = chatTextField.placeholder ?? ""
        chatTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        
        repeatVideo()
        
        animationView = .init(name: "loveStreamer")
        animationView?.frame = CGRect(x: 0, y: 0, width: 350, height: 350)
        animationView?.center = self.view.center
        animationView?.contentMode = .scaleAspectFill
        animationView?.loopMode = .loop
        guard let animationView = animationView else {
            return
        }
        view.addSubview(animationView)
        view.bringSubviewToFront(animationView)
        animationView.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.animationView?.stop()
            self.animationView?.isHidden = true
        }
        
        view.bringSubviewToFront(tableView)
        view.bringSubviewToFront(chatTextField)
        view.bringSubviewToFront(quitButton)
        view.bringSubviewToFront(sendButton)
        view.bringSubviewToFront(chatView)
        view.bringSubviewToFront(shareButton)
        view.bringSubviewToFront(streamerView)
        view.bringSubviewToFront(sendGiftButton)
        view.bringSubviewToFront(chatButton)
        view.bringSubviewToFront(announcementLabel)
        
        generateTextMaskForChat()
        
        let swipeRight = UISwipeGestureRecognizer(target:self, action:#selector(swipe(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target:self, action:#selector(swipe(_:)))
        swipeRight.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkFollow()
        addKeyboardObserver()
        fetchStreamerAvatar()
        fetchStreamerNickname()
        fetchStreamerOnlineViewers()
        handle = Auth.auth().addStateDidChangeListener({ auth, user in
            
            //檢查是否登入狀態
            guard
                user != nil,
                Auth.auth().currentUser != nil,
                let user = Auth.auth().currentUser
            else{
                //換到主執行緒上執行
                DispatchQueue.main.async {
                    self.webSocketConnect() // 連接webSocket
                }
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
                    DispatchQueue.main.async {
                        self.webSocketConnect() // 連接webSocket
                    }
                    return
                }
                
                self.key = "\(nameStr)"
                print("我的暱稱是\(self.key)")
                DispatchQueue.main.async {
                    self.webSocketConnect() // 連接webSocket
                }
            }
        })
    }
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "goToStreamerInfoVC"{
    //            let vc = segue.destination as? StreamerInfoVC
    //            vc?.delegate = self
    //            vc?.configure(head_photo: streamerAvatar, nickname: streamerNickname, online_num: streamerOnlineViewers, stream_title: streamerTitle, tags: streamerTags)
    //        }
    //    }
    
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
    
    @IBAction func btnShowKeyboardClicked(_ sender: UIButton) {
        chatButton.isHidden = true // 隱藏聊天按鈕
        shareButton.isHidden = true // 隱藏分享按鈕
        sendGiftButton.isHidden = true // 隱藏送禮物按鈕
        chatTextField.isHidden = false // 取消隱藏聊天文字方塊
        sendButton.isHidden = false // 取消隱藏傳送按鈕
        chatTextField.becomeFirstResponder() // 使聊天文字方塊成為第一響應
    }
    
    @IBAction func sendGiftPress(_ sender: UIButton) {
        guard loginStatus == true else { return showAlert(title: NSLocalizedString("SystemMessage", comment: "系統訊息"), message: NSLocalizedString("LoginStatusSendGiftMessage", comment: "請先註冊會員後才能送主播禮物!")) }
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StreamerGiftVC") as? StreamerGiftVC {
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }
    }
    
    @IBAction func streamerInfoPress(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StreamerInfoVC") as? StreamerInfoVC {
            vc.configure(head_photo: streamerAvatar, nickname: streamerNickname, online_num: streamerOnlineViewers, stream_title: streamerTitle, tags: streamerTags)
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }
    }
    
    @IBAction func sendChat(_ sender: UIButton) {
        let chat = chatTextField.text ?? ""
        let newChat = chat.trimmingCharacters(in: CharacterSet.whitespaces) // 去除空白字元
        
        guard newChat.count != 0 else {
            print("請輸入文字")
            showAlert(title: NSLocalizedString("SystemMessage", comment: "系統訊息"), message: NSLocalizedString("PleaseEnterText", comment: "請輸入文字"))
            chatTextField.text = nil
            return
        }
        
        if chat.isEmpty {
            print("請輸入文字")
            showAlert(title: NSLocalizedString("SystemMessage", comment: "系統訊息"), message: NSLocalizedString("PleaseEnterText", comment: "請輸入文字"))
        } else {
            send()
        }
        chatTextField.text = nil
        chatTextField.resignFirstResponder()
    }
    
    @IBAction func followButtonPress(_ sender: UIButton) {
        guard loginStatus == true else { return showAlert(title: NSLocalizedString("SystemMessage", comment: "系統訊息"), message: NSLocalizedString("LoginStatusFollowMessage", comment: "請先註冊會員後才能關注主播!")) }
        
        if follow == false {
            follow = true
            //            userDefaults.setValue(follow, forKey: "streamerFollow")
            let reference = Firestore.firestore().collection("Users")
            let userData = ["isFollow\(streamerNicknameLabel.text ?? "")": follow] as [String: Bool]
            reference.document((user?.email)!).setData(userData, merge: true) { error in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("successfully write in!")
                }
            }
            followButton.setTitle(NSLocalizedString("Following", comment: "關注中"), for: .normal)
            self.view.makeToast(NSLocalizedString("FollowSuccess", comment: "關注成功"), position: .center)
            
            sendFollow()
            
            follow = true
        } else {
            follow = false
            //            userDefaults.setValue(follow, forKey: "streamerFollow")
            let reference = Firestore.firestore().collection("Users")
            let userData = ["isFollow\(streamerNicknameLabel.text ?? "")": follow] as [String: Bool]
            reference.document((user?.email)!).setData(userData, merge: true) { error in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("successfully write in!")
                }
            }
            followButton.setTitle(NSLocalizedString("Follow", comment: "關注"), for: .normal)
            self.view.makeToast(NSLocalizedString("FollowCancel", comment: "取消關注"), position: .center)
        }
    }
    
    @IBAction func shareButtonPress(_ sender: UIButton) {
        guard let image = UIImage(named: "paopao.png"), let url = URL(string: "https://github.com/nianchenhao/LiveStreamingPractice") else { return }
        let shareSheetVC = UIActivityViewController(activityItems: [image, url], applicationActivities: nil)
        present(shareSheetVC, animated: true)
    }
    
    @IBAction func quitChatPress(_ sender: UIButton) {
        let controller = UIAlertController(title: "", message: NSLocalizedString("LeaveStudio", comment: "確定離開此直播間"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("NotQuit", comment: "先不要"), style: .cancel)
        
        
        let imgTitle = UIImage(named: "brokenHeart.png")
        let imgViewTitle = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        imgViewTitle.image = imgTitle
        
        controller.view.addSubview(imgViewTitle)
        
        let quitAction = UIAlertAction(title: NSLocalizedString("Quit", comment: "立馬走"), style: .default, handler: { _ in
            self.disconnection()
            self.dismiss(animated: true)
            self.videoPlayer?.pause()
        })
        controller.addAction(cancelAction)
        controller.addAction(quitAction)
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Function
    @objc func swipe(_ recognizer:UISwipeGestureRecognizer){
        if recognizer.direction == .right {
            print("向右滑动")
            streamerView.isHidden = true
            quitButton.isHidden = true
            announcementLabel.isHidden = true
            chatView.isHidden = true
        } else if recognizer.direction == .left {
            print("向左滑动")
            streamerView.isHidden = false
            quitButton.isHidden = false
            announcementLabel.isHidden = false
            chatView.isHidden = false
        }

        let point=recognizer.location(in: self.view)
        //这个点是滑动的起点
        print(point.x)
        print(point.y)
    }
    
    func fetchStreamerAvatar() {
        guard let streamerAvatar = streamerAvatar else { return }
        guard let url = URL(string: streamerAvatar) else { return }
        do {
            let data = try Data(contentsOf: url)
            let image = UIImage(data: data)
            streamerAvatarButton.setImage(image, for: .normal)
        } catch {
            print("image is error")
        }
    }
    
    func fetchStreamerNickname() {
        guard let streamerNickname = streamerNickname else { return }
        streamerNicknameLabel.text = streamerNickname
    }
    
    func fetchStreamerOnlineViewers() {
        guard let streamerOnlineViewers = streamerOnlineViewers else { return }
        streamerOnlineViewersLabel.text = String(streamerOnlineViewers) + "人"
    }
    
    func checkFollow() {
        
        // 判斷有沒有登入，有登入的話獲取使用者的email
        guard
            let user = Auth.auth().currentUser,
            let email = user.email
        else {
            print("尚未登入，無法獲取使用者的email")
            return
        }

        let reference = Firestore.firestore().collection("Users")
        reference.document(email).getDocument { snapshot, error in
           
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let snapshotData = snapshot!.data()?["isFollow\(self.streamerNicknameLabel.text ?? "")"] else {return}
            
            guard let defaultFollow = snapshotData as? Bool else{return}
            self.follow = defaultFollow
   
            guard self.follow == true else { return }
            
            self.followButton.setTitle(NSLocalizedString("Following", comment: "關注中"), for: .normal)
        }
        
//        //拿看看值，沒拿到的話直接return出去
//        guard
//            let defaultFollow = userDefaults.value(forKey: "streamerFollow") as? Bool
//        else {
//            print("沒存過值")
//            return
//        }
//        print("已存過值 為\(defaultFollow)")
//        //修改follow
//        follow = defaultFollow
//
//        //如果為true 修改按鈕的title
//        guard follow == true else{
//            return
//        }
//        followButton.setTitle(NSLocalizedString("Following", comment: "關注中"), for: .normal)
    }
    
    func repeatVideo() {
        let videoURL = Bundle.main.url(forResource: "hime3", withExtension: ".mp4")
        let player = AVQueuePlayer()
        videoPlayer = player
        let item = AVPlayerItem(url: videoURL!)
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        
        looper = AVPlayerLooper(player: player, templateItem: item)
        self.videoPlayer?.play()
    }
    
    func generateTextMaskForChat() {
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.1)
        gradientLayer.colors = [UIColor.clear.withAlphaComponent(0).cgColor, UIColor.clear.withAlphaComponent(1.0).cgColor]
        gradientLayer.locations = [0,1.0]
        gradientLayer.rasterizationScale = UIScreen.main.scale
        gradientLayer.frame = chatView.bounds
        chatView.layer.mask = gradientLayer
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("OkButton", comment: "確定"), style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - 設定WebSocket
    func webSocketConnect() {
        guard
            let urlString = "wss://client-dev.lottcube.asia/ws/chat/chat:app_test?nickname=\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlString)
        else {
            return
        }
        print("我傳的URL\(urlString)")
        let request = URLRequest(url: url)
        webSocket = URLSession.shared.webSocketTask(with: request)
        webSocket?.resume()
        receive()
    }
    
    func disconnection() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        chatArray.removeAll()
        userNameToChat.removeAll()
    }
    
    func ping() {
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        })
    }
    
    func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
    }
    
    func send() {
        //        let sendText = chatTextField.text!
        guard let sendText = chatTextField.text else { return }
        let message = URLSessionWebSocketTask.Message.string("{\"action\": \"N\",\"content\":\"\(sendText)\"}")
        webSocket?.send(message) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func sendFollow() {
        let following = NSLocalizedString("Following", comment: "關注中")
        let message = URLSessionWebSocketTask.Message.string("{\"action\": \"N\",\"content\":\"\(following)\"}")
        webSocket?.send(message) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func sendGift(gift: String) {
        let message = URLSessionWebSocketTask.Message.string("{\"action\": \"N\",\"content\":\"送了\(gift)\"}")
        webSocket?.send(message) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func receive() {
        webSocket?.receive { result in
            switch result {
            case .failure(let error):
                print("websocket收到錯誤訊息: \(error.localizedDescription)")
            case .success(let message):
                switch message {
                case .string(let text):
                    let data = text.data(using: .utf8)
                    do {
                        let test = try JSONDecoder().decode(WsRespone.self, from: data!)
                        guard let sender_role = test.sender_role else { return }
                        switch sender_role {
                        case -1:
                            self.chatArray.append(test.body!.text!)
                            self.userNameToChat.append((test.body!.nickname ?? "") + "：")
                        case 5:
                            let preferredLang = Bundle.main.preferredLocalizations.first! as NSString
                            print("當前系統語言：\(preferredLang)")
                            
                            switch String(describing: preferredLang) {
                            case "zh-Hant", "zh-TW", "zh-HK":
                                self.chatArray.append(test.body!.content!.tw!)
                            case "zh-Hans":
                                self.chatArray.append(test.body!.content!.cn!)
                            default:
                                self.chatArray.append(test.body!.content!.en!)
                            }
                            self.userNameToChat.append(NSLocalizedString("System", comment: "『系統』"))
                        case 0:
                            self.userNameToChat.append(test.body!.entry_notice!.username!)
                            switch test.body!.entry_notice!.action {
                            case "enter":
                                self.chatArray.append(NSLocalizedString("Enter", comment: "進入直播間"))
                            case "leave":
                                self.chatArray.append(NSLocalizedString("Leave", comment: "離開直播間"))
                            default:
                                print("錯誤")
                            }
                        default:
                            print("無法辨識的用戶,錯誤處理")
                        }
                    } catch {
                        print("json error")
                    }
                default:
                    print("錯誤1")
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            self.receive()
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to socket")
        receive()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close connection with reason")
    }
    
}

// MARK: - 設定TableView
extension StreamerVideoVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatroomTableViewCell
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1) // 對整個tableView翻轉
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1) // 對cell進行翻轉
        cell.backgroundColor = .clear // cell背景透明
        let index = chatArray.count - 1 - indexPath.row // 對調index上下順序由下至上
        cell.chatTextView.text = "\(userNameToChat[index]) \(chatArray[index])"
        cell.chatTextView.layer.cornerRadius = 15
        return cell
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
}

extension StreamerVideoVC: StreamerInfoVCDelegate {
    func followChat() {
        sendFollow()
    }
    
    func sendStatus(text: String) {
        followButton.setTitle(text, for: .normal)
    }
}

extension StreamerVideoVC: StreamerGiftVCDelegate {
    func sendGift(giftName: String) {
        sendGift(gift: giftName)
    }
}

// MARK: - 虛擬鍵盤事件處理
extension StreamerVideoVC {
    func addKeyboardObserver() {
        // 因為selector寫法只要指定方法名稱即可，參數則是已經定義好的NSNotification物件，所以不指定參數的寫法「#selector(keyboardWillShow)」也可以
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        // 能取得鍵盤高度就讓view上移鍵盤高度，否則上移view的1/3高度
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRect.height
            chatViewLayoutConstraint.constant = keyboardHeight - 10
            
        }
        //        else {
        //            view.frame.origin.y = -view.frame.height / 3
        //        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // 讓view回復原位
        chatViewLayoutConstraint.constant = 15
        chatButton.isHidden = false // 取消隱藏聊天按鈕
        shareButton.isHidden = false // 取消隱藏分享按鈕
        sendGiftButton.isHidden = false // 取消隱藏送禮物按鈕
        chatTextField.isHidden = true // 隱藏聊天文字方塊
        sendButton.isHidden = true // 隱藏傳送按鈕
    }
    
    // 當畫面消失時取消監控鍵盤開闔狀態
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        Auth.auth().removeStateDidChangeListener(handle!)
        webSocket?.cancel(with: .goingAway, reason: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
}

extension StreamerVideoVC: UITextFieldDelegate {		
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.returnKeyType == UIReturnKeyType.send {
            sendChat(sendButton)
        }
        return true
    }
}


