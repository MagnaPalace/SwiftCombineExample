//
//  StringExtension.swift
//  SwiftAsyncExample
//
//  Created by Takeshi Kayahashi on 2022/05/26.
//

import Foundation

extension String {
    
    enum Localize: String {
        // Alert
        case errorAlertTitle
        case confirmAlertTitle
        case closeAlertButtonTitle
        case networkCommunicationFailedMessage
        // User
        case addUserViewTitle
        case notCompletedInputFieldMessage
        case addUserFailedMessage
        
        var text: String {
            return self.rawValue.localized
        }
    }
    
    /// 文章のローカライズ呼び出し
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
}
