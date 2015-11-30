//
//  TweetsTableView.swift
//  twitter
//
//  Created by Lê Quang Bửu on 11/29/15.
//  Copyright © 2015 Lê Quang Bửu. All rights reserved.
//

import UIKit
import AlamofireImage
import SwiftMoment

class TweetDetailViewCell: UITableViewCell {
  
  @IBOutlet var retweetInfoView: UIView!
  @IBOutlet var retweetMessageLabel: UILabel!
  @IBOutlet var profileImageTopConstraint: NSLayoutConstraint!
  @IBOutlet var profileImageView: UIImageView!
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var screenNameLabel: UILabel!
  @IBOutlet var screenCreatedAtLabel: UILabel!
  @IBOutlet var contentLabel: UILabel!
  @IBOutlet var replyButton: UIButton!
  @IBOutlet var retweetButton: UIButton!
  @IBOutlet var favoriteButton: UIButton!
  
  var tweet: TweetState.Entity! {
    didSet {
      profileImageView.af_setImageWithURL(
        NSURL(string: tweet.userProfileImageURLString)!,
        placeholderImage: nil,
        filter: RoundedCornersFilter(radius: CGFloat(24)),
        imageTransition: .CrossDissolve(0.2)
      )
      nameLabel.text = tweet.userName
      screenNameLabel.text = String(format: "@%@", arguments: [tweet.userScreenName])
      contentLabel.text = tweet.text
      screenCreatedAtLabel.text = tweet.screenCreatedAt
      
      retweetButton.setTitle(String(format: " %d", arguments: [tweet.retweetCount]), forState: .Normal)
      favoriteButton.setTitle(String(format: " %d", arguments: [tweet.favoriteCount]), forState: .Normal)
      
      retweetButton.tintColor = tweet.retweeted ? Colors.nephritis : Colors.mischka
      favoriteButton.tintColor = tweet.favorited ? UIColor.orangeColor() : Colors.mischka
      
      if let retweeterScreenName = tweet.retweeterScreenName {
        retweetInfoView.hidden = false
        profileImageTopConstraint.constant = 24
        retweetMessageLabel.text = String(format: "%@ retweeted", arguments: [retweeterScreenName])
        
      } else {
        retweetInfoView.hidden = true
        profileImageTopConstraint.constant = 0
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    accessoryType = .None
    separatorInset = UIEdgeInsetsZero
    layoutMargins = UIEdgeInsetsZero
    
    [(String, UIButton!)](
      [
        ("reply-icon", replyButton),
        ("retweet-icon", retweetButton),
        ("star-icon", favoriteButton)
      ]
      ).forEach { (imageName, button) -> () in
        let origImage = UIImage(named: imageName);
        let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        
        button.setImage(tintedImage, forState: .Normal)
        button.tintColor = Colors.mischka
        button.setTitle("", forState: .Normal)
        button.contentHorizontalAlignment = .Left
    }
  }
  
  @IBAction func handleReplyButtonTap(sender: AnyObject) {
//    delegate?.tweetCell(replyToTweetInCell: self)
  }
  
  @IBAction func handleRetweetButtonTap(sender: AnyObject) {
    Store.sharedInstance.retweet(tweet)
  }
  
  @IBAction func handleFavoriteButtonTap(sender: AnyObject) {
    Store.sharedInstance.toggleFavoritedTweet(tweet.id)
  }
}
