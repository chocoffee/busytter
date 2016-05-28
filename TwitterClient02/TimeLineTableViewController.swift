//
//  TimeLineTableViewController.swift
//  TwitterClient02
//
//  Created by guest on 2016/04/25.
//  Copyright © 2016年 JEC. All rights reserved.
//

import UIKit
import Accounts
import Social

class TimeLineTableViewController: BaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellStringName = "Cell"
        tableView.alwaysBounceVertical = true
        
    }
    
    override func generateRequest() -> SLRequest {
        return generateRequest("")
    }
    
    override func generateRequest(max_id: String) -> SLRequest {
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        let params:[String:AnyObject]
        if max_id != ""{
            params = ["include_rts" : "0",
                      "trim_user" : "0",
                      "count" : "20",
                      "max_id": max_id]
        }else{
            params = ["include_rts" : "0",
                      "trim_user" : "0",
                      "count" : "20"]
        }
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: SLRequestMethod.GET,
                                URL: url,
                                parameters: params)
        
        return request
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
