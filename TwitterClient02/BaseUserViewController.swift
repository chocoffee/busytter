//
//  BaseUserViewController.swift
//  TwitterClient02
//
//  Created by guest on 2016/05/27.
//  Copyright © 2016年 JEC. All rights reserved.
//

import UIKit
import Accounts
import Social

//  users/showのapiを投げる部分が複数あったため、こちらも親クラス作成してまとめた
class BaseUserViewController: UIViewController, TimeLineProtocol {
    var twitterAccount = ACAccount()

    let inputFormatter = NSDateFormatter()
    let exportFormatter = NSDateFormatter()
    var toGetUserInfoId = ""
    var userInfoArray: [String:AnyObject] = [:]
    var userStatus: UserInfo?
    var httpMessage = ""
    var protectedMark = ""
    let mainQueue = dispatch_get_main_queue()
    let imageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        if toGetUserInfoId == "" {
            toGetUserInfoId = twitterAccount.username
        }
        inputFormatter.locale = NSLocale(localeIdentifier: "en_US")
        inputFormatter.dateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
        
        exportFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        exportFormatter.dateFormat = "アカウント設立日：yyyy年MM月dd日"
        requestTimeLine()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func requestTimeLine(){
        let request = generateRequest()
        let handler = generateRequestHandler()
        request.account = twitterAccount
        startProcessing()
        request.performRequestWithHandler(handler)
    }
    
    func generateRequest() -> SLRequest{
        let url = NSURL(string: "https://api.twitter.com/1.1/users/show.json")
        let params = ["screen_name" : toGetUserInfoId]
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: SLRequestMethod.GET,
                                URL: url,
                                parameters: params)
        return request
    }
    
    func generateRequestHandler() -> SLRequestHandler {
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
            self.stopProcessing()
        }
        return handler
    }
    
    func startProcessing() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func stopProcessing() {
        dispatch_async(self.mainQueue, {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    func parseJSON(result: [String:AnyObject]) -> UserInfo {
        guard let name = result["name"] as? String else {
            fatalError("Parse error!") }
        guard let description = result["description"] as? String else {
            fatalError("Parse error!")
        }
        guard let followers = result["followers_count"] as? Int else {
            fatalError("Parse Error!")
        }
        guard let following = result["friends_count"] as? Int else {
            fatalError("Parse Error!")
        }
        guard let favoriteCount = result["favourites_count"] as? Int else {
            fatalError("Parse Error!")
        }
        guard let totalTweet = result["statuses_count"] as? Int else {
            fatalError("Parse Error!")
        }
        guard let joinedDate = result["created_at"] as? String else {
            fatalError("Parse Error!")
        }
        guard let protected = result["protected"] as? Bool else {
            fatalError("Parse Error!")
        }
        guard let profileImageUrlHttps = result["profile_image_url_https"] as? String else {
            fatalError("Parse error!") }
        return UserInfo(
            screen_name:toGetUserInfoId,
            user_name: name,
            description: description,
            followers: followers,
            following: following,
            favorites: favoriteCount,
            totalTweet: totalTweet,
            joinedDate: exportFormatter.stringFromDate(inputFormatter.dateFromString(joinedDate)!),
            profileImageUrlHttps: profileImageUrlHttps,
            protected: protected
        )
    }
}
