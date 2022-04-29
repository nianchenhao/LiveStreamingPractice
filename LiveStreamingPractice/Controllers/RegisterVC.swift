//
//  RegisterVC.swift
//  LiveStreamingPractice
//
//  Created by Class on 2022/3/29.
//

import UIKit
import Firebase
import FirebaseFirestore

class RegisterVC: UIViewController {
    
    @IBOutlet weak var avatorImage: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: PasswordTextField!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var checkLabel: UILabel!
    
    private let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.layer.cornerRadius = 20
        
        resetUIElement()
        
        avatorImage.layer.borderWidth = 1
        avatorImage.layer.masksToBounds = false
        avatorImage.layer.borderColor = UIColor.black.cgColor
        avatorImage.layer.cornerRadius = avatorImage.frame.height/2
        avatorImage.clipsToBounds = true
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        nickNameTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardObserver()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSetAvator"{
            let vc = segue.destination as? SetAvatorVC
            vc?.delegate = self
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - @IBAction
    @IBAction func signUp(_ sender: UIButton) {
        
        let email = emailTextField.text ?? ""
        if email.isEmpty {
            checkLabel.text = NSLocalizedString("CheckEmail", comment: "請輸入電子郵件")
        }
        let password = passwordTextField.text ?? ""
        if password.isEmpty {
            checkLabel.text = NSLocalizedString("CheckPassword", comment: "請輸入密碼")
        }
        let nickName = nickNameTextField.text ?? ""
        if nickName.isEmpty {
            checkLabel.text = NSLocalizedString("CheckNickName", comment: "請輸入暱稱")
        } else if let account = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: account, password: password) { user, error in
                
                //                if let changRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                //                    changRequest.displayName = self.nickNameTextField.text
                //                }
                
                if error != nil {
                    print(error!)
                    self.showAlert(title: NSLocalizedString("RegistrationFailed", comment: "註冊失敗"), message: error?.localizedDescription ?? "")
                } else {
                    let reference = Firestore.firestore()
                    if let nickName = self.nickNameTextField.text, let account = self.emailTextField.text {
                        let userData = ["nickName": nickName, "account": account] as [String: Any]
                        reference.collection("Users").document(account).setData(userData) { error in
                            if error != nil {
                                print(error!.localizedDescription)
                            } else {
                                print("successfully write in!")
                            }
                        }
                    }
                    print("註冊成功！")
                    self.saveData()
                    let alertController = UIAlertController(title: NSLocalizedString("RegistrationSuccess", comment: "註冊成功"), message: NSLocalizedString("LoginAgain", comment: "請再次登入"), preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OkButton", comment: "確定"), style: .default, handler: { _ in
                        guard let avatorImage = self.avatorImage.image else { return }
                        self.uploadToCloud(img: avatorImage)
                        do {
                            try Auth.auth().signOut()
                        } catch {
                            print("error, there was a problem logging out")
                        }
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Function
    func resetUIElement() {
        let backItem = UIBarButtonItem(
            image: UIImage(named: "titlebarBack")?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(backItemAction(_:))
        )
        self.navigationItem.leftBarButtonItem = backItem
    }
    
    @objc func backItemAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func saveData() {
        let userDefaults = UserDefaults.standard
        /* 先將UIImage轉成Data方能存檔 */
        if let image = avatorImage.image?.jpegData(compressionQuality: 1.0) {
            userDefaults.set(image, forKey: "image")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("OkButton", comment: "確定"), style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    func uploadToCloud(img: UIImage) {
        guard let emailTextField = emailTextField.text else { return }
        let userImageRef = storage.child("userImage").child("\(emailTextField).jpg")
        if let jpgData = img.jpegData(compressionQuality: 1.0){
            //執行上傳圖片
            userImageRef.putData(jpgData, metadata: nil) { metadata, error in
                guard error == nil else {
                    print("Failed to upload")
                    return
                }
                print("上傳成功")
            }
        }
    }
    
}

extension RegisterVC: SetAvatorVCDelegate {
    func selectPhoto(photo: UIImage) {
        avatorImage.image = photo
    }
}

// MARK: - 虛擬鍵盤事件處理
extension RegisterVC {
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
            view.frame.origin.y = -keyboardHeight
        } else {
            view.frame.origin.y = -view.frame.height / 3
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // 讓view回復原位
        view.frame.origin.y = 0
    }
    
    // 當畫面消失時取消監控鍵盤開闔狀態
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension RegisterVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nickNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
        default:
            break
        }
        return true
    }
}
