//
//  WebViewController.swift
//  TwitterClient02
//
//  Created by guest on 2016/05/13.
//  Copyright © 2016年 JEC. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    var openURL = NSURL()
    private var webView = WKWebView()
    private var progressView = UIProgressView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: view.bounds, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view = webView
        let request = NSURLRequest(URL: openURL)
        webView.loadRequest(request)
        progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Bar)
        progressView.frame = CGRectMake(0, 20 + 44, view.bounds.size.width, 2)
        view.addSubview(progressView)
        webView.addObserver(self, forKeyPath:"estimatedProgress", options:.New, context:nil)

    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    override func observeValueForKeyPath(keyPath:String?, ofObject object:AnyObject?, change:[String:AnyObject]?, context:UnsafeMutablePointer<Void>) {
        switch keyPath! {
        case "estimatedProgress":
            if let progress = change![NSKeyValueChangeNewKey] as? Float {
                progressView.progress = progress
            }
        default:
            break
        }
    }
    
    override func viewWillLayoutSubviews() {
        progressView.frame = CGRectMake(0, calcBarHeight(), view.bounds.size.width, 2)
    }

    override func prefersStatusBarHidden() -> Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webView(webView: WKWebView,didStartProvisionalNavigation: WKNavigation) {
        startProcessig()
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        progressView.progress = 0.0
        stopProcessing()
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: NSError) {
        progressView.progress = 0.0
        stopProcessing()
        print("Request Error: An error occurred while requeting: \(error)")
    }
    
    private func startProcessig() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

    private func stopProcessing() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    private func calcBarHeight() -> CGFloat {
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let navigationBarHeight = navigationController?.navigationBar.frame.size.height ?? 0
        return statusBarHeight + navigationBarHeight
    }
}
