//
//  TweetSheetViewController.swift
//  TwitterClient02
//
//  Created by guest on 2016/04/22.
//  Copyright © 2016年 JEC. All rights reserved.
//

import UIKit
import Accounts
import Social

//  TabBarController内の新規ツイートpost
//  Replyはモーダルとして独立しているため同じViewにsegueでつなげることは難しいと判断
//  書く量よりUIを優先した

class TweetSheetViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AccountProtocol {
    let mainQueue = dispatch_get_main_queue()
    var twitterAccount = ACAccount()
    var id:String? = ""
    var text:String? = ""
    var inputImage: UIImage? = nil
    
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userId.text = "by @\(twitterAccount.username)"
        tweetTextView.text = text
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    //  「Done」ボタンでキーボード引っ込める
    @IBAction func dismissKeyBoard(sender: UIButton) {
        tweetTextView.resignFirstResponder()
    }
    
    //  「Images」でカメラロール呼び出して画像添付
    @IBAction func selectImageAction(sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePickerController.allowsEditing = false
        imagePickerController.delegate = self
        self.presentViewController(imagePickerController,animated:true ,completion:nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if let info = editingInfo, let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            inputImage = editedImage
            imageView.image = editedImage
        }else{
            inputImage = image
            imageView.image = image
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //  「POST」でリクエスト発行
    @IBAction func tweetWithCustomSheet(sender: UIButton) {
        let request = generateRequest()
        let handler = generateRequestHandler()
        request.account = twitterAccount
        startProcessing()
        request.performRequestWithHandler(handler)
    }
    
    func generateRequest() -> SLRequest {
        var url = NSURL()
        
        //  画像が選択されているかいないかで条件分岐
        //  投げるapiを変える
        if inputImage != nil {
            url = NSURL(string: "https://api.twitter.com/1.1/statuses/update_with_media.json")!
        }else {
            url = NSURL(string:"https://api.twitter.com/1.1/statuses/update.json")!
        }
        
        let params:[NSObject:AnyObject]
        
        //  このViewからはReplyは飛ばないが一応残しておく
        if let id = self.id {
            params = ["status":tweetTextView.text,"in_reply_to_status_id":id]
        }else{
            params = ["status":tweetTextView.text]
        }
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
            requestMethod: SLRequestMethod.POST,
            URL: url,
            parameters: params)
        
        if inputImage != nil {
            let image = inputImage
            let imageData = UIImageJPEGRepresentation(image!, 0.5)
            request.addMultipartData(imageData,
                withName: "media[]",
                type: "multipart/form-data",
                filename: nil)
        }
        return request
    }

    func generateRequestHandler() -> SLRequestHandler {
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
    
    func startProcessing() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func stopProcessing() {
        dispatch_async(mainQueue, {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
}
