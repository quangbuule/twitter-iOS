//
//  TweetComposeViewController.swift
//  twitter
//
//  Created by Lê Quang Bửu on 11/29/15.
//  Copyright © 2015 Lê Quang Bửu. All rights reserved.
//

import UIKit

class TweetComposeViewController: UIViewController, UITextViewDelegate {
  
  @IBOutlet var remainingCharCountLabel: UILabel!
  @IBOutlet var tweetButton: UIButton!
  @IBOutlet var contentTextView: UITextView!

  var tweetToReply: TweetState.Entity?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tweetButton.backgroundColor = Colors.picton
    tweetButton.layer.cornerRadius = 3
    tweetButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    
    contentTextView.delegate = self
    
    if tweetToReply != nil {
      contentTextView.text = String(format: "@%@ ", arguments: [tweetToReply!.userScreenName])
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    textViewDidChange(contentTextView)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    contentTextView.becomeFirstResponder()
  }
  
  func textViewDidChange(textView: UITextView) {
    let remainingCharCount = 160 - textView.text.utf16.count
    
    remainingCharCountLabel.text = String(format: "%d", arguments: [remainingCharCount])
    
    if (remainingCharCount < 160) {
      tweetButton.enabled = true
      tweetButton.alpha = 1
      
    } else {
      tweetButton.enabled = false
      tweetButton.alpha = 0.5
    }
  }
  
  @IBAction func handleCancelButtonTap(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func handleTweetButtonTap(sender: AnyObject) {
    Store.sharedInstance.tweet(text: contentTextView.text)
    dismissViewControllerAnimated(true, completion: nil)
  }
}
