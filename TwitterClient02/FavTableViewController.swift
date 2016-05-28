//
//  FavTableViewController.swift
//  TwitterClient02
//
//  Created by guest on 2016/05/20.
//  Copyright © 2016年 JEC. All rights reserved.
//

import UIKit
import Accounts
import Social

class FavTableViewController: BaseTableViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellStringName = "FavCell"
        self.navigationController?.title = "Favorites"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func generateRequest() -> SLRequest {
        return generateRequest("")
    }
    
    override func generateRequest(max_id: String) -> SLRequest {
        let url = NSURL(string: "https://api.twitter.com/1.1/favorites/list.json")
        let params:[String:AnyObject]
        if max_id != ""{
            params = ["include_rts" : "0",
                      "trim_user" : "0",
                      "count" : "20",
                      "max_id":max_id]
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
}
