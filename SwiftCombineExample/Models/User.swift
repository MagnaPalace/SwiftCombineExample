//
//  User.swift
//  SwiftAsyncExample
//
//  Created by Takeshi Kayahashi on 2022/05/21.
//

import Foundation

class User: Codable {
    
    private(set) var userId: Int
    private(set) var name: String
    private(set) var comment: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name
        case comment
    }
    
}

extension User {
    enum Key: String, CaseIterable {
        case userId = "user_id"
        case name = "name"
        case comment = "comment"
    }
}

extension User: Hashable {
    
    // Hashableプロトコルに準拠するために必要なhash(into:)メソッド
    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
        hasher.combine(name)
        hasher.combine(comment)
    }
    
    // Hashableプロトコルに準拠するために必要な==演算子
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.userId == rhs.userId && lhs.name == rhs.name && lhs.comment == rhs.comment
    }
    
}

