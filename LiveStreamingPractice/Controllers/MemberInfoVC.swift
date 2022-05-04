//
//  MemberInfoVC.swift
//  LiveStreamingPractice
//
//  Created by Class on 2022/3/30.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class MemberInfoVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var avatorImage: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    
    private let storage = Storage.storage().reference()
    var handle: AuthStateDidChangeListenerHandle?
    var isSignIn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        
        avatorImage.layer.borderWidth = 1
        avatorImage.layer.masksToBounds = false
        avatorImage.layer.borderColor = UIColor.black.cgColor
        avatorImage.layer.cornerRadius = avatorImage.frame.height/2
        avatorImage.clipsToBounds = true
        
        signOutButton.layer.cornerRadius = 20
        //        loadData()
        //        downloadImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                guard let userEmail = user.email else { return }
                let fileReference = self.storage.child("userImage/\(userEmail).jpg")
                fileReference.getData(maxSize: .max) { data, error in
                    if let error = error {
                        print(error)
                    } else {
                        guard let data = data else {
                            return
                        }
                        let image = UIImage(data: data)
                        self.avatorImage.image = image
                    }
                }
                let email = user.email
                let emailStr = String(email!)
                let userEmailStr = emailStr
                accountLabel.text = NSLocalizedString("AccountEmail", comment: "帳號：") + userEmailStr
                let reference = Firestore.firestore().collection("Users")
                reference.document(emailStr).getDocument{ snapshot, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        if let snapshot = snapshot {
                            let snapshotData = snapshot.data()?["nickName"]
                            if let nameStr = snapshotData as? String {
                                let userNameStr = nameStr
                                self.nickNameLabel.text = NSLocalizedString("AccountNickname", comment: "暱稱：") + userNameStr
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - @IBAction
    @IBAction func editAvatarImage(_ sender: UIButton) {
        let controller = UIAlertController(title: "", message: NSLocalizedString("EditAvatar", comment: "編輯頭像"), preferredStyle: .actionSheet)
        
        let action = UIAlertAction(title: NSLocalizedString("AlbumSelection", comment: "從相簿選取"), style: .default) { action in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        
        controller.addAction(action)
        
        let photoAction = UIAlertAction(title: NSLocalizedString("Photograph", comment: "拍照"), style: .default) { action in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        
        controller.addAction(photoAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "取消"), style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func editNickname(_ sender: UIButton) {
        let editAlert = UIAlertController(title: NSLocalizedString("EditNickname", comment: "修改暱稱"), message: NSLocalizedString("EnterNewNickname", comment: "請輸入新暱稱"), preferredStyle: .alert)
        editAlert.addTextField { textField in
            textField.placeholder = NSLocalizedString("NewNicknamePlaceholder", comment: "新暱稱")
        }
        guard let newNickname = editAlert.textFields?.first else { return }
        let newName = newNickname as UITextField
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "取消"), style: .cancel, handler: nil)
        let ok = UIAlertAction(title: NSLocalizedString("OkButton", comment: "確定"), style: .default) { alertAction in
            guard newName.text != "" else {
                return self.showAlert(title: NSLocalizedString("SystemMessage", comment: "系統訊息"), message: NSLocalizedString("NewNicknameNotNil", comment: "新暱稱不可空白"))
            }
            guard let newName = newName.text else { return }
            let reference = Firestore.firestore()
            guard let user = Auth.auth().currentUser else { return }
            let userData = ["nickName": newName] as [String: Any]
            reference.collection("Users").document(user.email ?? "").setData(userData, merge: true) { error in
                if error != nil {
                    print("error")
                } else {
                    self.nickNameLabel.text = NSLocalizedString("AccountNickname", comment: "暱稱：") + newName
                    print("successfully write in!")
                }
            }
        }
        editAlert.addAction(cancel)
        editAlert.addAction(ok)
        present(editAlert, animated: true, completion: nil)
    }
    
    @IBAction func signOut(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "PersonalVC") as? PersonalVC {
                controller.modalPresentationStyle = .currentContext
                self.navigationController?.viewControllers = [controller]
            }
        } catch {
            print("error, there was a problem logging out")
        }
    }
    
    // MARK: - Function
    func uploadToCloud(img: UIImage) {
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                guard let userEmail = user.email else { return }
                let userImageRef = storage.child("userImage").child("\(userEmail).jpg")
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
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("OkButton", comment: "確定"), style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - 設定ImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        avatorImage.image = image
        uploadToCloud(img: image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    //    func downloadImage() {
    //        let fileReference = storage.child("userImage/avatorImage.jpg")
    //
    //        fileReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
    //            if let error = error {
    //                print(error)
    //            } else {
    //                let image = UIImage(data: data!)
    //                self.avatorImage.image = image
    //            }
    //        }
    //    }
    
    //    func loadData() {
    //        let userDefaults = UserDefaults.standard
    //
    //        if let image = userDefaults.data(forKey: "image") {
    //            avatorImage.image = UIImage(data: image)
    //        }
    //    }
    
}

