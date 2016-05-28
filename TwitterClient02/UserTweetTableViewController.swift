//
//  UserTweetTableViewController.swift
//  TwitterClient02
//
//  Created by guest on 2016/05/27.
//  Copyright © 2016年 JEC. All rights reserved.
//

import UIKit
import Accounts
import Social

class UserTweetTableViewController: BaseTableViewController {
    var screen_name = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        cellStringName = "UserCell"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func generateRequest() -> SLRequest {
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")
        let params = ["include_rts" : "0",
                      "trim_user" : "0",
                      "count" : "20",
                      "screen_name":screen_name]
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: SLRequestMethod.GET,
                                URL: url,
                                parameters: params)
        return request
    }

}
