//
//  Chatroom.swift
//  LiveStreamingPractice
//
//  Created by Class on 2022/4/14.
//

import Foundation

struct WsRespone: Codable {
    let event: String?
    let room_id: String?
    let sender_role: Int?
    let body: RoomSource?
    let time: String?
}

struct RoomSource: Codable {
    let chat_id: String?
    let account: String?
    let nickname: String?
    let recipient: String?
    let type: String?
    let text: String?
    let accept_time: String?
    let info: Obj?
    let content: Country?
    let entry_notice: user?
}

struct Obj: Codable {
    let last_login: Int?
    let is_ban: Int?
    let level: Int?
    let is_guardian: Int?
    let badges: Bool?
}

struct Country: Codable {
    let cn: String?
    let en: String?
    let tw: String?
}

struct user: Codable {
    let username: String?
    let action: String?
}
