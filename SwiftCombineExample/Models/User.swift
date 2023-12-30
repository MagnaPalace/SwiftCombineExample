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
