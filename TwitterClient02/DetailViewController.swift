//
//  DetailViewController.swift
//  TwitterClient02
//
//  Created by guest on 2016/05/09.
//  Copyright © 2016年 JEC. All rights reserved.
//

import UIKit
import Accounts
import Social

class DetailViewController: UIViewController, AccountProtocol {
    var twitterAccount = ACAccount()
    private let mainQueue = dispatch_get_main_queue()
    var myScreenName = ""
    var profileImage = UIImage()
    var screenName = ""
    var name = ""
    var text = ""
    var idStr = ""
    var protected = false
    var retweeted = 0
    var favorited = 0
    var isRetweeted = false
    var isFavorited = false
    var postTime = ""
    var protectedMark = ""

    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screen_nameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetedCountLabel: UILabel!
    @IBOutlet weak var favoritedCountLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myScreenName = twitterAccount.username
        //  触れないときはボタンの色とenableを変更する
        deleteButton.enabled = false
        if protected {
            retweetButton.enabled = false
            retweetButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.protectedMark = "🔒"
        }
        if myScreenName == self.screenName {
            print("oppai")
            retweetButton.enabled = false
            retweetButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            deleteButton.enabled = true
            deleteButton.setTitleColor(UIColor(red: 177 / 255, green: 134 / 255, blue: 255 / 255, alpha: 1.0), forState: .Normal)
        }
        
        myScreenName = twitterAccount.username
        profileImageView.image = profileImage
        nameLabel.text = name + protectedMark
        screen_nameLabel.text = "@\(screenName)"
        postTimeLabel.text = postTime
        tweetTextView.text = text
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.navigationController = navigationController!
        setLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toReplySegue" {
            let nextViewController = segue.destinationViewController as! ReplyViewController
            nextViewController.id = self.idStr
            nextViewController.sendScreenName = self.screenName
            nextViewController.myId = twitterAccount.username
            nextViewController.twitterAccount = twitterAccount
        }
    }
    
    @IBAction func retweet() {
        var code = 0
        if isRetweeted {code = 2}
        print("code\(code)")
        let request = generateRequest(code)
        let handler = generateRequestHandler(code)
        request.account = twitterAccount
        startProcessing()
        request.performRequestWithHandler(handler)
    }
    
    @IBAction func favorite(sender: UIButton) {
        var code = 1
        if isFavorited {code = 3}
        print("code\(code)")
        let request = generateRequest(code)
        let handler = generateRequestHandler(code)
        request.account = twitterAccount
        startProcessing()
        request.performRequestWithHandler(handler)
    }
    
    @IBAction func deleteMyTweet(sender: UIButton) {
        let request = generateRequest(4)
        let handler = generateRequestHandler(4)
        request.account = twitterAccount
        startProcessing()
        request.performRequestWithHandler(handler)
    }
    
    //  引数によってどのapiを投げるか決定する
    private func generateRequest(which: Int) -> SLRequest {
        var url = NSURL()
        switch which {
        case 0: //  create retweet
            url = NSURL(string: "https://api.twitter.com/1.1/statuses/retweet/\(idStr).json")!
        case 1: //  create fav
            url = NSURL(string: "https://api.twitter.com/1.1/favorites/create.json?id=\(idStr)")!
        case 2: //  delete retweet
            url = NSURL(string: "https://api.twitter.com/1.1/statuses/unretweet/\(idStr).json")!
        case 3: //  delete fav
            url = NSURL(string: "https://api.twitter.com/1.1/favorites/destroy.json?id=\(idStr)")!
        case 4: //  delete tweet
            url = NSURL(string: "https://api.twitter.com/1.1/statuses/destroy/\(idStr).json")!
        default:
            url = NSURL(string: "")!
        }
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: SLRequestMethod.POST,
                                URL: url,
                                parameters: nil)
        return request
    }
    
    private func generateRequestHandler(which: Int) -> SLRequestHandler {
        let handler: SLRequestHandler = { postResponseData, urlResponse, error in
            if let requestError = error {
                print("Request Error: An error occurred while requesting: \(requestError)")
                self.stopProcessing()
                return
            }
            
            if urlResponse.statusCode < 200 || urlResponse.statusCode >= 300 {
                print("HTTP Error: The response status code is \(urlResponse.statusCode)")
                self.stopProcessing()
                return
            }
            
            let objectFromJSON: AnyObject
            do {
                objectFromJSON = try NSJSONSerialization.JSONObjectWithData(
                    postResponseData,
                    options: NSJSONReadingOptions.MutableContainers)
            } catch (let jsonError) {
                print("JSON Error: \(jsonError)")
                self.stopProcessing()
                return
            }
            self.stopProcessing()
        }
        return handler
    }
    
    private func startProcessing() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    private func stopProcessing() {
        dispatch_async(mainQueue, {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })

    }
    
    func setLabels() {
        retweetedCountLabel.text = "\(retweeted)"
        favoritedCountLabel.text = "\(favorited)"
    }
    
    @IBAction func goToReply(sender: UIButton) {
        performSegueWithIdentifier("toReplySegue", sender: nil)
    }
    
}
