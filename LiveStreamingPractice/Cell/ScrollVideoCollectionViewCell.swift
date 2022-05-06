//
//  ScrollVideoCollectionViewCell.swift
//  LiveStreamingPractice
//
//  Created by Robert_Nian on 2022/5/5.
//

import UIKit
import AVFoundation

protocol ScrollVideoCollectionViewCellDelegate: AnyObject {
    func userDidTapLeaveFromStreamerVideo()
    func videoPlayFromStreamerVideo()
    func videoPauseFromStreamerVideo()
}

class ScrollVideoCollectionViewCell: UICollectionViewCell, StreamerVideoVCDelegate {
    
    func userDidTapLeave() {
        self.delegate?.userDidTapLeaveFromStreamerVideo()
    }
    
    func videoPlay() {
        self.delegate?.videoPlayFromStreamerVideo()
    }
    
    
    func videoPause() {
        self.delegate?.videoPauseFromStreamerVideo()
    }
    
    
    static let identifier = "ScrollVideoCollectionViewCell"
    
    
    weak var delegate: ScrollVideoCollectionViewCellDelegate?
    var videoPlayer: AVPlayer?
    var looper: AVPlayerLooper?
    var model: VideoModel?
    
    var vc: StreamerVideoVC?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .black
        contentView.clipsToBounds = true
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewController(withIdentifier: "StreamerVideoVC") as? StreamerVideoVC
        vc?.delegate = self
        vc?.view.frame = self.bounds
//        vc?.videoPlay()
        
        self.contentView.addSubview(vc!.view)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    public func configure(with model: Streamer) {
//        configureVideo()
        vc?.configure(head_photo: model.head_photo, nickname: model.nickname, online_num: model.online_num, stream_title: model.stream_title, tags: [model.tags])
        vc?.prepareForReuse()
        
    }
    public func changesomething() {
//        vc.button.alpha = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
