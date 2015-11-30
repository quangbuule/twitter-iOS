//
//  TweetDetailViewController.swift
//  twitter
//
//  Created by Lê Quang Bửu on 11/29/15.
//  Copyright © 2015 Lê Quang Bửu. All rights reserved.
//

import UIKit
import RxSwift

class TweetDetailViewController: UIViewController {
  
  var disposeBag = DisposeBag()
  var tweet: TweetState.Entity!
  
  @IBOutlet var tableView: TweetDetailTableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self
    
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    
    title = "Tweet"
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    Store.sharedInstance
      .withLastState()
      .subscribeNext(stateDidChange)
      .addDisposableTo(disposeBag)
  }
  
  func shouldViewUpdate(nextTweet: TweetState.Entity) -> Bool {
    return true
    
    // TODO: TweetState.Entity must implement Equatable first
    //
    // return tweets.count != nextTweets.count ||
    //  tweets.enumerate().reduce(false, combine: { shouldUpdate, item in
    //    return shouldUpdate || item.element != nextTweets[item.index]
    //  })
  }
  
  func stateDidChange(state: Store.State) {
    let nextTweet = state.Tweet.tweet(tweet.id)
    
    if (shouldViewUpdate(nextTweet)) {
      tweet = nextTweet
      tableView.reloadData()
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillAppear(animated)
    disposeBag = DisposeBag()
  }
}

extension TweetDetailViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if (indexPath.row == 0) {
      let detailCell = tableView.dequeueReusableCellWithIdentifier("detailCell") as! TweetDetailViewCell
      
      detailCell.tweet = tweet
      return detailCell
    }
    
    return UITableViewCell()
  }
}
