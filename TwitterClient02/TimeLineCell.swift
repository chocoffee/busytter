//
//  TimeLineCell.swift
//  TwitterClient02
//
//  Created by guest on 2016/05/02.
//  Copyright © 2016年 JEC. All rights reserved.
//

import UIKit

class TimeLineCell: UITableViewCell {
    
    @IBOutlet weak var userIconImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNamelabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var postTime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
