//
//  UserDetailViewController.swift
//  TwitterClient02
//
//  Created by chocoffee on 2016/05/25.
//  Copyright © 2016年 JEC. All rights reserved.
//

import UIKit
import Social
import Accounts

class UserDetailViewController: BaseUserViewController {
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var introduce: UILabel!
    @IBOutlet weak var tweets: UILabel!
    @IBOutlet weak var favorites: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var joinedDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        if userStatus!.protected {
            protectedMark = "🔒"
        }
        screenName.text = "@\(userStatus!.screen_name)"
        introduce.text = userStatus!.description
        userName.text = userStatus!.user_name + protectedMark
        following.text = "following\n\(userStatus!.following)"
        followers.text = "followers\n\(userStatus!.followers)"
        favorites.text = "favorites\n\(userStatus!.favorites)"
        tweets.text = "tweet\n\(userStatus!.totalTweet)"
        joinedDate.text = userStatus!.joinedDate
        
        var icon = UIImage()
        dispatch_async(self.imageQueue, {
            guard let imageUrl = NSURL(string: self.userStatus!.profileImageUrlHttps) else {
                fatalError("URL Error!")
            }
            do {
                let imageData = try NSData(
                    contentsOfURL: imageUrl,
                    options:NSDataReadingOptions.DataReadingMappedIfSafe)
                icon = UIImage(data: imageData)!
            } catch (let imageError) {
                print("Image loading Error: (\(imageError))")
            }
            dispatch_async(self.mainQueue, {
                self.userIcon.image = icon
            })
        })
    }
}
