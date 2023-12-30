//
//  UserListTableViewCell.swift
//  SwiftAsyncExample
//
//  Created by Takeshi Kayahashi on 2022/05/21.
//

import UIKit

class UserListTableViewCell: UITableViewCell {

    @IBOutlet var userIdLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    
    var model: UserListTableViewCellModel!
    
    func initialize(model: UserListTableViewCellModel) {
        self.model = model
        
        userIdLabel.text = model.userNo.description
        nameLabel.text = model.name
        commentLabel.text = model.comment
    }

}
