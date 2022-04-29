//
//  SetAvatorVC.swift
//  LiveStreamingPractice
//
//  Created by Class on 2022/3/29.
//

import UIKit
import FirebaseStorage

protocol SetAvatorVCDelegate: AnyObject {
    func selectPhoto(photo: UIImage)
}

class SetAvatorVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var albumSelectButton: UIButton!
    @IBOutlet weak var photographButton: UIButton!
    
    private let storage = Storage.storage().reference()
    weak var delegate: SetAvatorVCDelegate!
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumSelectButton.layer.cornerRadius = 20
        photographButton.layer.cornerRadius = 20
        imagePickerController.delegate = self
        resetUIElement()
    }
    
    // MARK: - @IBAction
    @IBAction func cameraButtonPress(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func showAlbumPress(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
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
    
    // MARK: - 設定ImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        //        uploadToCloud(img: image)
        
        delegate?.selectPhoto(photo: image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //    func uploadToCloud(img: UIImage) {
    //        let userImageRef = storage.child("userImage").child("avatorImage.jpg")
    //        if let jpgData = img.jpegData(compressionQuality: 1.0){
    //            //執行上傳圖片
    //            userImageRef.putData(jpgData, metadata: nil) { metadata, error in
    //                guard error == nil else {
    //                    print("Failed to upload")
    //                    return
    //                }
    //                print("上傳成功")
    //            }
    //        }
    //    }
    
}

