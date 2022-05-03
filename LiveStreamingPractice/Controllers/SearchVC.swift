//
//  SearchVC.swift
//  LiveStreamingPractice
//
//  Created by Class on 2022/3/29.
//

import UIKit

class SearchVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var streamers = [Streamer]()
    var streamersResult = [Streamer]()
    var searchbar = UISearchBar()
    var searchResult = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchbar.delegate = self
        searchbar.placeholder = NSLocalizedString("SearchPlaceholder", comment: "")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(searchbar)
        fetchPhotos()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchbar.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width - 20, height: 50)
        collectionView.frame = CGRect(x: 0, y: view.safeAreaInsets.top + 55, width: view.frame.size.width, height: view.frame.size.height - 55)
    }
    
    // MARK: - Function
    func fetchPhotos() {
        guard let url = Bundle.main.url(forResource: "Streamers", withExtension: "json") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.streamers = searchResponse.result.lightyear_list
                    self.collectionView?.reloadData()
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func searchPhoto(name: String) {
        guard let url = Bundle.main.url(forResource: "Streamers", withExtension: "json") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
                DispatchQueue.main.async { [self] in
                    let nameArray = searchResponse.result.stream_list
                    let tmp = nameArray.filter { streamResult in
                        streamResult.nickname.localizedCaseInsensitiveContains(name) || streamResult.stream_title.localizedCaseInsensitiveContains(name) ||
                        streamResult.tags.localizedCaseInsensitiveContains(name)
                        // 不區分英文大小寫
                    }
                    print("有\(tmp.count)個值")
                    
                    if tmp.count == 0 {
                        self.streamersResult = searchResponse.result.lightyear_list
                        self.searchResult = false
                    } else {
                        self.streamersResult = tmp
                        self.searchResult = true
                    }
                    
                    self.streamers = searchResponse.result.lightyear_list
                    self.collectionView?.reloadData()
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchPhoto(name: searchBar.text ?? "")
    }
    
    // MARK: - 設定CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if searchResult {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if streamersResult.count == 0 {
            return streamers.count
        } else {
            if section == 0 {
                return streamersResult.count
            } else {
                return streamers.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchCollectionViewCell
        cell.imageView.image = UIImage(named: "paopao.png")
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.clipsToBounds = true
        cell.imageView.contentMode = .scaleAspectFill
        cell.contentView.layer.cornerRadius = 10
        
        if streamersResult.count == 0 {
            let completeLink = streamers[indexPath.row].head_photo
            cell.imageView.downloaded(from: completeLink)
            cell.nickNameLabel.text = streamers[indexPath.row].nickname
            cell.streamTitleLabel.text = streamers[indexPath.row].stream_title
//            cell.tagsLabel.text = "#" + streamers[indexPath.row].tags
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
            
            cell.tagsLabel.layer.cornerRadius = 5
            
            cell.onlineNumLabel.text = String(streamers[indexPath.row].online_num)
            // Create Attachment
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(named:"iconPersonal")
            imageAttachment.bounds = CGRect(x: 0, y: -5, width: 13, height: 13)
            // Create string with attachment
            let attachmentString = NSAttributedString(attachment: imageAttachment)
            // Initialize mutable string
            let completeText = NSMutableAttributedString(string: "")
            // Add image to mutable string
            completeText.append(attachmentString)
            // Add your text to mutable string
            let textAfterIcon = NSAttributedString(string: cell.onlineNumLabel.text ?? "0")
            completeText.append(textAfterIcon)
            cell.onlineNumLabel.textAlignment = .center
            cell.onlineNumLabel.attributedText = completeText
        } else {
            if indexPath.section == 0 {
                let completeLinkResult = streamersResult[indexPath.row].head_photo
                cell.imageView.downloaded(from: completeLinkResult)
                cell.nickNameLabel.text = streamersResult[indexPath.row].nickname
                cell.streamTitleLabel.text = streamersResult[indexPath.row].stream_title
//                cell.tagsLabel.text = "#" + streamersResult[indexPath.row].tags
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
                
                cell.tagsLabel.layer.cornerRadius = 5
                
                cell.onlineNumLabel.text = String(streamersResult[indexPath.row].online_num)
                // Create Attachment
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(named:"iconPersonal")
                imageAttachment.bounds = CGRect(x: 0, y: -5, width: 13, height: 13)
                // Create string with attachment
                let attachmentString = NSAttributedString(attachment: imageAttachment)
                // Initialize mutable string
                let completeText = NSMutableAttributedString(string: "")
                // Add image to mutable string
                completeText.append(attachmentString)
                // Add your text to mutable string
                let textAfterIcon = NSAttributedString(string: cell.onlineNumLabel.text ?? "0")
                completeText.append(textAfterIcon)
                cell.onlineNumLabel.textAlignment = .center
                cell.onlineNumLabel.attributedText = completeText
            } else {
                let completeLink = streamers[indexPath.row].head_photo
                cell.imageView.downloaded(from: completeLink)
                cell.nickNameLabel.text = streamers[indexPath.row].nickname
                cell.streamTitleLabel.text = streamers[indexPath.row].stream_title
                //                cell.tagsLabel.text = "#" + streamersResult[indexPath.row].tags
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
                
                cell.tagsLabel.layer.cornerRadius = 5
                
                cell.onlineNumLabel.text = String(streamers[indexPath.row].online_num)
                // Create Attachment
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(named:"iconPersonal")
                imageAttachment.bounds = CGRect(x: 0, y: -5, width: 13, height: 13)
                // Create string with attachment
                let attachmentString = NSAttributedString(attachment: imageAttachment)
                // Initialize mutable string
                let completeText = NSMutableAttributedString(string: "")
                // Add image to mutable string
                completeText.append(attachmentString)
                // Add your text to mutable string
                let textAfterIcon = NSAttributedString(string: cell.onlineNumLabel.text ?? "0")
                completeText.append(textAfterIcon)
                cell.onlineNumLabel.textAlignment = .center
                cell.onlineNumLabel.attributedText = completeText
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let controller = storyboard?.instantiateViewController(withIdentifier: "StreamerVideoVC") as? StreamerVideoVC {
            if streamersResult.count == 0 {
                let streamerAvatar = streamers[indexPath.row].head_photo
                let streamerNickname = streamers[indexPath.row].nickname
                let streamerOnlineViewers = streamers[indexPath.row].online_num
                let streamerTitle = streamers[indexPath.row].stream_title
                let tagArray = streamers[indexPath.row].tags.components(separatedBy: ",")
                
                controller.configure(head_photo: streamerAvatar, nickname: streamerNickname, online_num: streamerOnlineViewers, stream_title: streamerTitle, tags: tagArray)
            } else {
                if indexPath.section == 0 {
                    let streamerAvatar = streamersResult[indexPath.row].head_photo
                    let streamerNickname = streamersResult[indexPath.row].nickname
                    let streamerOnlineViewers = streamersResult[indexPath.row].online_num
                    let streamerTitle = streamers[indexPath.row].stream_title
                    let tagArray = streamers[indexPath.row].tags.components(separatedBy: ",")
                    
                    controller.configure(head_photo: streamerAvatar, nickname: streamerNickname, online_num: streamerOnlineViewers, stream_title: streamerTitle, tags: tagArray)
                } else {
                    let streamerAvatar = streamers[indexPath.row].head_photo
                    let streamerNickname = streamers[indexPath.row].nickname
                    let streamerOnlineViewers = streamers[indexPath.row].online_num
                    let streamerTitle = streamers[indexPath.row].stream_title
                    let tagArray = streamers[indexPath.row].tags.components(separatedBy: ",")
                    
                    controller.configure(head_photo: streamerAvatar, nickname: streamerNickname, online_num: streamerOnlineViewers, stream_title: streamerTitle, tags: tagArray)
                }
            }
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
        return UIEdgeInsets(top: 5 , left: 5, bottom: 5, right: 5)
    }
    
    // MARK: - 設定Collection View Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SearchHeaderView", for: indexPath) as? SearchHeaderCollectionReusableView {
                
                if indexPath.section == 0 {
                    if searchResult {
                        headerView.popularLabel.text = NSLocalizedString("SearchResult", comment: "搜尋結果")
                    } else {
                        headerView.popularLabel.text = NSLocalizedString("PopularStreamer", comment: "熱門推薦")
                    }
                } else {
                    headerView.popularLabel.text = NSLocalizedString("PopularStreamer", comment: "熱門推薦")
                }
                return headerView
            }
        default:
            return UICollectionReusableView()
        }
        return UICollectionReusableView()
    }
    
    // MARK: - 滾動收鍵盤
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}
