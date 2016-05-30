//
//  BaseTableViewController.swift
//  TwitterClient02
//
//  Created by guest on 2016/05/16.
//  Copyright © 2016年 JEC. All rights reserved.
//

import UIKit
import Accounts
import Social

//  4つのTableViewControllerの親クラス 
//  同じコードは全部まとめてみた

class BaseTableViewController: UITableViewController, TimeLineProtocol {
    var twitterAccount = ACAccount()
    let inputFormatter = NSDateFormatter()
    let exportFormatter = NSDateFormatter()
    var cellStringName = ""
    private var timeLineArray: [AnyObject] = []
    private var httpMessage = ""
    var max_id = ""
    var statusArray:[Status] = []
    let mainQueue = dispatch_get_main_queue()
    let imageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestTimeLine()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(BaseTableViewController.refreshTableView), forControlEvents: UIControlEvents.ValueChanged)
        
        inputFormatter.locale = NSLocale(localeIdentifier: "en_US")
        inputFormatter.dateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
        
        exportFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        exportFormatter.dateFormat = "HH:mm:ss"
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    @objc private func refreshTableView() {
        refreshControl?.beginRefreshing()
        requestTimeLine()
        refreshControl?.endRefreshing()
    }
    
    func requestTimeLine() {
        requestTimeLine(nil)
    }
    
    func requestTimeLine(max_id: String?){
        let request:SLRequest
        let handler: SLRequestHandler
        if let id = max_id{
            request = generateRequest(id)
            handler = generateRequestHandler(id)
        }else{
            request = generateRequest()
            handler = generateRequestHandler()
        }
        request.account = twitterAccount
        startProcessing()
        request.performRequestWithHandler(handler)
    }
    
    func generateRequest() -> SLRequest{
        return SLRequest()
    }
    
    func generateRequest(max_id:String) -> SLRequest{
        return SLRequest()
    }
    
    private func generateRequestHandler() -> SLRequestHandler {
        return generateRequestHandler("")
    }
    
    private func generateRequestHandler(max_id: String) -> SLRequestHandler {
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
                self.timeLineArray = try NSJSONSerialization.JSONObjectWithData(
                    getResponseData,
                    options: NSJSONReadingOptions.AllowFragments) as? [AnyObject] ?? []
            } catch (let jsonError) {
                print("JSON Error: \(jsonError)")
                self.stopProcessing()
                return
            }
            
            if max_id != "" {
                var sss = self.parseJSON(self.timeLineArray)
                if self.timeLineArray.count >= 3 {
                    for i in 1...self.timeLineArray.count - 1 {
                        self.statusArray.append(sss[i])
                        self.timeLineArray.removeAll()
                    }
                }
            }else {
                self.statusArray = self.parseJSON(self.timeLineArray)
            }
            self.stopProcessing()
        }
        return handler
    }
    
    private func parseJSON(json: [AnyObject]) -> [Status] {
        return json.map{ result in
            guard let created_at = result["created_at"] as? String else {
                fatalError("Parse Error!")
            }
            guard let text = result["text"] as? String else {
                fatalError("Parse error!") }
            guard let user = result ["user"] as? NSDictionary else {
                fatalError("Parse error!") }
            guard let protected = user["protected"] as? Bool else {
                fatalError("Parse Error!")
            }
            guard let screenName = user["screen_name"] as? String else {
                fatalError("Parse error!") }
            guard let profileImageUrlHttps =
                user["profile_image_url_https"] as? String else {
                    fatalError("Parse error!") }
            guard let idStr = result["id_str"] as? String else { fatalError("Prase error!") }
            guard let userName = user["name"] as? String else {fatalError("Prase error!")}
            guard let retweetedCount = result["retweet_count"] as? Int else {
                fatalError("Parse Error!")
            }
            guard let favoritedCount = result["favorite_count"] as? Int else {
                fatalError("Parse Error!")
            }
            guard let retweeted = result["retweeted"] as? Bool else {
                fatalError("Parse Error!")
            }
            guard let favorited = result["favorited"] as? Bool else {
                fatalError("Parse Error!")
            }
            return Status(
                text: text,
                screenName: screenName,
                profileImageUrlHttps: profileImageUrlHttps,
                idStr: idStr,
                userName:  userName,
                postTime: exportFormatter.stringFromDate(inputFormatter.dateFromString(created_at)!),
                protected: protected,
                retweetedCount: retweetedCount,
                favoritedCount:  favoritedCount,
                retweeted: retweeted,
                favorited: favorited
            )
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if statusArray.count == 0 {
            return 20
        }else {
            return statusArray.count
        }
    }
    
    func startProcessing() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func stopProcessing() {
        dispatch_async(self.mainQueue, {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellStringName, forIndexPath: indexPath) as! TimeLineCell
        
        var celltext = ""
        var celluserName = ""
        var cellName = ""
        var postTime = ""
        var cellImageViewImage = UIImage()
        var protected = false
        var protectedMark = ""
        
        if statusArray.count == 0 {
            if httpMessage != "" {
                celltext = httpMessage
            } else {
                celltext = "Loading..."
            }
        } else {
            let status = statusArray[indexPath.row]
            celltext = status.text
            celluserName = status.screenName
            cellName = status.userName
            postTime = status.postTime
            protected = status.protected
            if protected {
                protectedMark = "🔒"
            }
            dispatch_async(self.imageQueue, {
                guard let imageUrl = NSURL(string: status.profileImageUrlHttps) else {
                    fatalError("URL Error!")
                }
                do {
                    let imageData = try NSData(
                        contentsOfURL: imageUrl,
                        options:NSDataReadingOptions.DataReadingMappedIfSafe)
                    cellImageViewImage = UIImage(data: imageData)!
                } catch (let imageError) {
                    print("Image loading Error: (\(imageError))")
                }
                dispatch_async(self.mainQueue, {
                    cell.userIconImg.image = cellImageViewImage
                    cell.setNeedsLayout() // セルのみ再描画
                })
            })
            
        }
        let blank = UIImage(named: "blank.png")
        cell.tweetTextLabel?.text = celltext
        cell.nameLabel?.text = "@\(celluserName)"
        cell.userIconImg.image = blank
        cell.userNamelabel.text = cellName + protectedMark
        cell.postTime.text = postTime
        return cell
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if(self.tableView.contentOffset.y == (self.tableView.contentSize.height - self.tableView.bounds.size.height)){
            self.max_id = self.statusArray[statusArray.count - 1].idStr
            requestTimeLine(max_id)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.destinationViewController {
        case let detailVC as DetailViewController:
            let indexPath = tableView.indexPathForSelectedRow
            let status = statusArray[indexPath!.row]
            detailVC.text = status.text
            detailVC.screenName = status.screenName
            detailVC.idStr = status.idStr
            detailVC.twitterAccount = twitterAccount
            detailVC.name = status.userName
            detailVC.postTime = status.postTime
            detailVC.protected = status.protected
            detailVC.isRetweeted = status.retweeted
            detailVC.isFavorited = status.favorited
            detailVC.retweet_count = status.retweetedCount
            detailVC.favorite_count = status.favoritedCount
            
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! TimeLineCell
            detailVC.profileImage = cell.userIconImg.image!
            
        case let userVC as UserInfoViewController:
            let cell = sender!.superview?!.superview as! TimeLineCell
            guard let indexPath = tableView.indexPathForCell(cell)?.row else {
                fatalError("index not found!")
            }
            let status = statusArray[indexPath]
            
            userVC.toGetUserInfoId = status.screenName
            userVC._userIcon = cell.userIconImg.image!
            userVC.twitterAccount = twitterAccount
        default:
            print("Segue has no parameters.")
        }
    }
}
