//
//  Config.swift
//  SwiftAsyncExample
//
//  Created by Takeshi Kayahashi on 2022/05/21.
//

import Foundation

let BASE_URL = "http://localhost:8888/"
let API_URL = "api/"
    
enum UserApi: String {
    case store = "user/store"
    case all = "user/all"
}
