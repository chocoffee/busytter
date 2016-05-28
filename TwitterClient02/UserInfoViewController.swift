//
//  UserInfoViewController.swift
//  TwitterClient02
//
//  Created by guest on 2016/05/20.
//  Copyright © 2016年 JEC. All rights reserved.
//

import UIKit
import Accounts
import Social

//  タイムラインのアイコンを押した時に呼ばれる画面
class UserInfoViewController: BaseUserViewController{
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var userIntroduce: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var tweetCount: UILabel!
    @IBOutlet weak var favoriteCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followersCount: UILabel!
    var _userIcon = UIImage()
    var name = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        userIcon.image = _userIcon
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func dismissAction(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func generateRequestHandler() -> SLRequestHandler {
        let handler: SLRequestHandler = { getResponseData, urlResponse, error in
            if let requestError = error {
                print("Request Error: An error occurred while requesting: \(requestError)")
                self.httpMessage = "HTTPエラー発生"
                self.stopProcessing()
                return
            }
            if urlResponse.statusCode < 200 || urlResponse.statusCode >= 300 {
                print("HTTP Error: The response status code is \(urlResponse.statusCode)")
                self.httpMessage = "HTTPエラー発生"
                self.stopProcessing()
                return
            }
            do {
                self.userInfoArray = try NSJSONSerialization.JSONObjectWithData(
                    getResponseData,
                    options: NSJSONReadingOptions.AllowFragments) as? [String:AnyObject] ?? [:]
            } catch (let jsonError) {
                print("JSON Error: \(jsonError)")
                self.stopProcessing()
                return
            }
            self.userStatus = self.parseJSON(self.userInfoArray)
            dispatch_async(self.mainQueue, {
                self.setLabels()
            })
            self.stopProcessing()
        }
        return handler
    }
    
    func setLabels(){
        userId.text = "@\(userStatus!.screen_name)"
        userIntroduce.text = userStatus!.description
        userName.text = userStatus!.user_name
        followingCount.text = "following\n\(userStatus!.following)"
        followersCount.text = "followers\n\(userStatus!.followers)"
        favoriteCount.text = "favorites\n\(userStatus!.favorites)"
        tweetCount.text = "tweet\n\(userStatus!.totalTweet)"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nextViewController = segue.destinationViewController as? UserTweetTableViewController{
            nextViewController.screen_name = toGetUserInfoId
            nextViewController.twitterAccount = twitterAccount
        }
    }
}
