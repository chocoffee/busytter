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
    //  パラメータ用screen_nameをsegueで受け取り
    var screen_name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellStringName = "UserCell"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func generateRequest() -> SLRequest {
        return generateRequest("")
    }
    
    override func generateRequest(max_id: String) -> SLRequest {
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")
        let params:[String:AnyObject]
        if max_id != ""{
            params = ["screen_name" : screen_name,
                      "include_rts" : "0",
                      "trim_user" : "0",
                      "count" : "20",
                      "max_id":max_id]
        }else{
            params = ["screen_name" : screen_name,
                      "include_rts" : "0",
                      "trim_user" : "0",
                      "count" : "20"]
        }
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: SLRequestMethod.GET,
                                URL: url,
                                parameters: params)
        return request
    }
}
