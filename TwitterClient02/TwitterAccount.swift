//
//  TwitterAccount.swift
//  TwitterClient02
//
//  Created by guest on 2016/05/25.
//  Copyright © 2016年 JEC. All rights reserved.
//

import Foundation
import Social
import Accounts

//  通信の時に必ず使うものはプロトコルにして管理
protocol AccountProtocol {
    var twitterAccount: ACAccount {
        get set
    }
}

protocol TimeLineProtocol:AccountProtocol {
    func requestTimeLine()
}
