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

class StreamerVideoVC: UIViewController, URLSessionWebSocketDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var chatViewLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var streamerView: UIView!
    @IBOutlet weak var followButton: UIButton!
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        quitButton.layer.cornerRadius = quitButton.frame.width / 2
        quitButton.layer.masksToBounds = true
        sendButton.layer.cornerRadius = quitButton.frame.width / 2
        sendButton.layer.masksToBounds = true
        chatTextField.layer.cornerRadius = 15
        chatTextField.layer.masksToBounds = true
        shareButton.layer.cornerRadius = shareButton.frame.width / 2
        streamerView.layer.cornerRadius = 20
        followButton.layer.cornerRadius = followButton.frame.width / 2
        
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
        
        generateTextMaskForChat()
        checkFollow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardObserver()
        
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
                        switch test.sender_role! {
                        case -1:
                            self.chatArray.append(test.body!.text!)
                            self.userNameToChat.append(test.body!.nickname ?? "")
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
        cell.chatTextView.text = "\(userNameToChat[index]) : \(chatArray[index])"
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
            chatViewLayoutConstraint.constant = keyboardHeight - 30
            
        }
        //        else {
        //            view.frame.origin.y = -view.frame.height / 3
        //        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // 讓view回復原位
        chatViewLayoutConstraint.constant = 15
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


