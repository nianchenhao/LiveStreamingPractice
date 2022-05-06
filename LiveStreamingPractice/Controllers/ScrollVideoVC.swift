//
//  ScrollVideoVC.swift
//  LiveStreamingPractice
//
//  Created by Robert_Nian on 2022/5/5.
//

import UIKit

class ScrollVideoVC: UIViewController, ScrollVideoCollectionViewCellDelegate {
    func videoPlayFromStreamerVideo() {
        print("")
    }
    
    func videoPauseFromStreamerVideo() {
        print("")
    }

    func userDidTapLeaveFromStreamerVideo() {
        print("testdelegate")
        self.dismiss(animated: true)
    }
    

    private var collectionView: UICollectionView?
    private var streamers = [Streamer]()
    
    var streamerAvatar: String?
    var streamerNickname: String?
    var streamerOnlineViewers: Int?
    var streamerTitle: String?
    var streamerTags: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        for _ in 0..<10 {
//            let model = VideoModel(videoFileName: "hime3", videoFileFormat: "mp4")
//            data.append(model)
//        }
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        layout.itemSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView?.register(ScrollVideoCollectionViewCell.self, forCellWithReuseIdentifier: ScrollVideoCollectionViewCell.identifier)
        collectionView?.isPagingEnabled = true
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.contentInsetAdjustmentBehavior = .never
        collectionView?.dataSource = self
        collectionView?.delegate = self
        view.addSubview(collectionView!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
//    public func configure(head_photo: String?, nickname: String?, online_num: Int?, stream_title: String?, tags: [String]?) {
//        if head_photo != nil, nickname != nil, online_num != nil, stream_title != nil, tags != nil {
//            self.streamerAvatar = head_photo
//            self.streamerNickname = nickname
//            self.streamerOnlineViewers = online_num
//            self.streamerTitle = stream_title
//            self.streamerTags = tags
//        }
//
//    }／
    
    public func configure(streamers: [Streamer]) {
        self.streamers = streamers
    }
    
}

extension ScrollVideoVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return streamers.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let model = data[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScrollVideoCollectionViewCell.identifier, for: indexPath) as! ScrollVideoCollectionViewCell
        cell.delegate = self
        cell.configure(with: streamers[indexPath.row])
//        cell.configure(with: model)
//        cell.changesomething()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScrollVideoCollectionViewCell.identifier, for: indexPath) as! ScrollVideoCollectionViewCell
        cell.videoPlay()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScrollVideoCollectionViewCell.identifier, for: indexPath) as! ScrollVideoCollectionViewCell
        cell.videoPause()
    }
    
    
}
