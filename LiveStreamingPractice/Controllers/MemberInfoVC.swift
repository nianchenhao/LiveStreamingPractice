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

class MemberInfoVC: UIViewController {
    
    @IBOutlet weak var avatorImage: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    
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
                accountLabel.text = "帳號：\(emailStr)"
                let reference = Firestore.firestore().collection("Users")
                reference.document(emailStr).getDocument{ snapshot, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        if let snapshot = snapshot {
                            let snapshotData = snapshot.data()?["nickName"]
                            if let nameStr = snapshotData as? String {
                                self.nickNameLabel.text = "暱稱：\(nameStr)"
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func editNickname(_ sender: UIButton) {
        let editAlert = UIAlertController(title: "修改暱稱", message: "請輸入您的新暱稱", preferredStyle: .alert)
        editAlert.addTextField { textField in
            textField.placeholder = "新的暱稱"
        }
        guard let newNickname = editAlert.textFields?.first else { return }
        let newName = newNickname as UITextField
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "確定", style: .default) { alertAction in
            guard let newName = newName.text else { return }
            let reference = Firestore.firestore()
            guard let user = Auth.auth().currentUser else { return }
            let userData = ["nickName": newName] as [String: Any]
            reference.collection("Users").document(user.email ?? "").setData(userData) { error in
                if error != nil {
                    print("error")
                } else {
                    self.nickNameLabel.text = "暱稱：\(newName)"
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

