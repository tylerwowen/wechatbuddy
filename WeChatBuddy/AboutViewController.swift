//
//  AboutViewController.swift
//  WeChatBuddy
//
//  Created by Tyler Weimin Ouyang on 8/8/15.
//  Copyright (c) 2015 Tyler. All rights reserved.
//

import UIKit

let URL = NSURL(string: "http://tylerwowen.github.io/wechatbuddy")
let URLReq = NSURLRequest(URL: URL!)

class AboutViewController: UIViewController, UIWebViewDelegate{
  
  @IBOutlet weak var indicator: UIActivityIndicatorView!
  @IBOutlet weak var webView: UIWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    GradientBackgroundSetter.setBackgrooundColorForView(self.view)
    webView.loadRequest(URLReq)
    webView.delegate = self
  }
  
  @IBAction func goBackButton(sender: UIBarButtonItem) {
    webView.goBack()
  }
  
  @IBAction func share(sender: UIBarButtonItem) {
    let string = "Hey, check this app out! It's really cool! :P "
    let URL = NSURL(string: "http://tylerwowen.github.io/wechatbuddy")
    let array:[AnyObject!] = [string, URL]
    
    let activityViewController = UIActivityViewController(activityItems: array, applicationActivities: nil)
    
    self.presentViewController(activityViewController, animated: true) {
      () -> Void in
      
    }
  }
  
  func webViewDidStartLoad(webView: UIWebView) {
    indicator.startAnimating()
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    indicator.stopAnimating()
  }
  
}
