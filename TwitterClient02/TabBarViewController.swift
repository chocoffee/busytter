//
//  TabBarViewController.swift
//  TwitterClient02
//
//  Created by guest on 2016/05/16.
//  Copyright © 2016年 JEC. All rights reserved.
//

import UIKit
import Accounts
import Social

class TabBarViewController: UITabBarController{
    var twitterAccount = ACAccount() 

    //  TabBarController内のすべてのViewにAccount情報投げる
    override func viewDidLoad() {
        super.viewDidLoad()
        if let viewControllers = self.viewControllers {
            for tmp in viewControllers{
                if var vc = tmp as? AccountProtocol{
                    vc.twitterAccount = twitterAccount
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? BaseTableViewController{
            vc.twitterAccount = twitterAccount
        }
    }
}
