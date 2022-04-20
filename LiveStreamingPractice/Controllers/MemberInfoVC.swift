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
        
        print("我進來viewDidLoad")
        //        loadData()
        //        downloadImage()
        
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let fileReference = self.storage.child("userImage/\(user.email!).jpg")
                fileReference.getData(maxSize: .max) { data, error in
                    if let error = error {
                        print(error)
                    } else {
                        let image = UIImage(data: data!)
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

