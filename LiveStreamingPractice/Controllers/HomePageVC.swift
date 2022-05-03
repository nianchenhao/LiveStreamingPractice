//
//  HomePageVC.swift
//  LiveStreamingPractice
//
//  Created by Class on 2022/3/29.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Lottie

class HomePageVC: UIViewController, URLSessionWebSocketDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var streamers = [Streamer]()
    var fullScreenSize: CGSize!
    private let storage = Storage.storage().reference()
    //    let animationView = AnimationView(name: "welcome")
    var animationView: AnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchPhotos()
        
        animationView = .init(name: "welcome")
        animationView?.frame = CGRect(x: 0, y: 0, width: 350, height: 350)
        animationView?.center = self.view.center
        animationView?.contentMode = .scaleAspectFill
        animationView?.loopMode = .loop
        
        guard let animationView = animationView else {
            return
        }
        
        view.addSubview(animationView)
        animationView.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.animationView?.stop()
            self.animationView?.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    // MARK: - IBAction
    @IBAction func toggleDarkMode(_ sender: UISwitch) {
        if #available(iOS 13.0, *) {
            let appDelegate = UIApplication.shared.windows.first
            
            if sender.isOn {
                appDelegate?.overrideUserInterfaceStyle = .dark
                return
            }
            
            appDelegate?.overrideUserInterfaceStyle = .light
            return
        } else {
            
        }
    }
    
    // MARK: - Function
    func fetchPhotos() {
        guard let url = Bundle.main.url(forResource: "Streamers", withExtension: "json") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.streamers = searchResponse.result.stream_list
                    self.collectionView.reloadData()
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    // MARK: - 設定Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return streamers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! CustomCollectionViewCell
        cell.imageView.image = UIImage(named: "paopao.png")
        cell.imageView.contentMode = .scaleAspectFill
        let completeLink = streamers[indexPath.row].head_photo
        cell.imageView.downloaded(from: completeLink)
        cell.imageView.clipsToBounds = true
        cell.imageView.contentMode = .scaleAspectFill
        cell.nickNameLabel.text = streamers[indexPath.row].nickname
        cell.streamTitleLabel.text = streamers[indexPath.row].stream_title
        
        let tagArray = streamers[indexPath.row].tags.components(separatedBy: ",")
        if tagArray.count > 1 {
            cell.tagsLabel.text = "#\(tagArray[0])  #\(tagArray[1])"
        } else {
            if tagArray[0] != "" {
                cell.tagsLabel.text = "#\(streamers[indexPath.row].tags)"
            } else {
                cell.tagsLabel.text = ""
            }
        }
        //        cell.tagsLabel.text = "#" + streamers[indexPath.row].tags
        
        cell.tagsLabel.layer.cornerRadius = 5
        
        cell.onlineNumLabel.text = String(streamers[indexPath.row].online_num)
        
        let content = NSMutableAttributedString(string: "")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named:"iconPersonal")
        imageAttachment.bounds = CGRect(x: 0, y: -5, width: 13, height: 13)
        content.append(NSAttributedString(attachment: imageAttachment))
        content.append(NSAttributedString(string: cell.onlineNumLabel.text ?? "0"))
        cell.onlineNumLabel.attributedText = content
        
        cell.contentView.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let controller = storyboard?.instantiateViewController(withIdentifier: "StreamerVideoVC") as? StreamerVideoVC {
            let streamerAvatar = streamers[indexPath.row].head_photo
            let streamerNickname = streamers[indexPath.row].nickname
            let streamerOnlineViewers = streamers[indexPath.row].online_num
            let streamerTitle = streamers[indexPath.row].stream_title
//            let tags = streamers[indexPath.row].tags
            
            let tagArray = streamers[indexPath.row].tags.components(separatedBy: ",")
//            if tagArray.count > 1 {
//                cell.tagsLabel.text = "#\(tagArray[0])  #\(tagArray[1])"
//            } else {
//                cell.tagsLabel.text = "#\(streamers[indexPath.row].tags)"
//            }

            controller.configure(head_photo: streamerAvatar, nickname: streamerNickname, online_num: streamerOnlineViewers, stream_title: streamerTitle, tags: tagArray)
            
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
        print("Selected section \(indexPath.section) and row \(indexPath.row)")
    }
    
    // MARK: - 設定Collection View Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = collectionView.bounds
        let heightVal = self.view.frame.height
        let widthVal = self.view.frame.width
        let cellSize = (heightVal < widthVal) ? bounds.height/2 : bounds.width/2
        return CGSize(width: cellSize - 10, height: cellSize - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    // MARK: - 設定Collection View Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeHeaderView", for: indexPath) as? HomeHeaderCollectionReusableView {
                if Auth.auth().currentUser != nil {
                    let user = Auth.auth().currentUser
                    if let user = user {
                        let fileReference = self.storage.child("userImage/\(user.email!).jpg")
                        fileReference.getData(maxSize: .max) { data, error in
                            if let error = error {
                                print(error)
                            } else {
                                guard let data = data else {
                                    return
                                }
                                let image = UIImage(data: data)
                                headerView.userImage.image = image
                                headerView.userImage.layer.borderWidth = 1
                                headerView.userImage.layer.masksToBounds = false
                                headerView.userImage.layer.borderColor = UIColor.black.cgColor
                                headerView.userImage.layer.cornerRadius = headerView.userImage.frame.height/2
                                headerView.userImage.clipsToBounds = true
                            }
                        }
                        let email = user.email
                        let emailStr = String(email!)
                        let reference = Firestore.firestore().collection("Users")
                        reference.document(emailStr).getDocument{ snapshot, error in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                if let snapshot = snapshot {
                                    let snapshotData = snapshot.data()?["nickName"]
                                    if let nameStr = snapshotData as? String {
                                        headerView.nickNameLabel.text = nameStr
                                    }
                                }
                            }
                        }
                    }
                } else {
                    headerView.userImage.image = UIImage(named: "topPic")
                    headerView.nickNameLabel.text = NSLocalizedString("VisitorNickname", comment: "訪客")
                }
                return headerView
            }
        default:
            return UICollectionReusableView()
        }
        return UICollectionReusableView()
    }
    
}

// MARK: - Extension UIImageView
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}


