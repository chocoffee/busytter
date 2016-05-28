//
//  Status.swift
//  TwitterClient02
//
//  Created by guest on 2016/05/02.
//  Copyright © 2016年 JEC. All rights reserved.
//

import UIKit

struct Status {
    var text: String    //  ツイート本文
    var screenName: String  //  @Twitter
    var profileImageUrlHttps: String    //アイコン画像
    var idStr: String   //  各ツイートに振られた識別ID
    var userName: String    //  @じゃない方の名前
    var postTime: String    //  投稿時間
    var protected: Bool //  鍵垢か否か
    var retweetedCount :Int //  rtされた数
    var favoritedCount: Int //  favされた数
    var retweeted: Bool //  自分がrtしたか否か
    var favorited: Bool //  じぶんがfavしたか否か
}