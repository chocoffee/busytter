//
//  ReplyViewController.swift
//  TwitterClient02
//
//  Created by guest on 2016/05/26.
//  Copyright © 2016年 JEC. All rights reserved.
//

import UIKit
import Accounts
import Social

class ReplyViewController: UIViewController , UITextViewDelegate, AccountProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var twitterAccount = ACAccount()
    private let mainQueue = dispatch_get_main_queue()
    @IBOutlet weak var userId: UILabel!
    
    var id :String?
    var sendScreenName = ""
    var myId = ""
    var inputImage: UIImage? = nil
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var tweetTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        userId.text = "by @\(myId)"
        tweetTextView.text = "@\(sendScreenName) "
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func dismissViewController(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func chooseImage(sender: UIButton) {
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

    @IBAction func sendReplyAction(sender: UIButton) {
        let request = generateRequest()
        let handler = generateRequestHandler()
        request.account = twitterAccount
        startProcessing()
        request.performRequestWithHandler(handler)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func generateRequest() -> SLRequest {
        var url = NSURL()
        if inputImage != nil {
            url = NSURL(string: "https://api.twitter.com/1.1/statuses/update_with_media.json")!
        }else {
            url = NSURL(string:"https://api.twitter.com/1.1/statuses/update.json")!
        }
        
        let params:[NSObject:AnyObject]
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
    @IBAction func dismissKeyBoard(sender: UIButton) {
        tweetTextView.resignFirstResponder()
    }
}
