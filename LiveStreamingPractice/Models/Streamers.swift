//
//  Streamers.swift
//  LiveStreamingPractice
//
//  Created by Class on 2022/3/31.
//

import Foundation

struct SearchResponse: Codable {
    let result: ResaultData
}
struct ResaultData: Codable {
    let stream_list: [Streamer]
    let lightyear_list: [Streamer]
}
struct Streamer: Codable {
    let stream_title: String //直播標題
    let nickname: String //暱稱
    let head_photo: String //頭貼
    let tags: String //標籤
    let online_num: Int //人數
    let streamer_id: Int //直播主ID
}

