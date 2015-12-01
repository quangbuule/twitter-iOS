//
//  TimelineViewController.swift
//  twitter
//
//  Created by Lê Quang Bửu on 11/29/15.
//  Copyright © 2015 Lê Quang Bửu. All rights reserved.
//

import UIKit
import RxSwift

class TimelineViewController: UIViewController {
  
  var disposeBag = DisposeBag()
  var tweets: [TweetState.Entity] = []
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  let refreshControl = UIRefreshControl()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    refreshControl.tintColor = UIColor.lightGrayColor()
    refreshControl.addTarget(self, action: Selector("refresh:"), forControlEvents: .ValueChanged)
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.addSubview(refreshControl)

    activityIndicator.startAnimating()
    title = "Home"
    Store.sharedInstance.dispatch(loadTweetsWithCollectionId: TweetState.homeCollectionId)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    Store.sharedInstance
      .withLastState()
      .subscribeNext(stateDidChange)
      .addDisposableTo(disposeBag)
  }
  
  func shouldViewUpdate(nextTweets: [TweetState.Entity]) -> Bool {
    return true
    
    // TODO: TweetState.Entity must implement Equatable first
    //
    // return tweet != nextTweet
  }
  
  func stateDidChange(state: Store.State) {
    let cid = TweetState.homeCollectionId
    let Tweet = state.Tweet
    let nextTweets = Tweet.tweets(cid)
    
    if (shouldViewUpdate(nextTweets)) {
      tweets = nextTweets
      print(tweets.count)
      activityIndicator.hidden = !(Tweet.isTweetsFetching(cid) && Tweet.isTweetsLoaded(cid))
      refreshControl.endRefreshing()
      
      if (Tweet.isTweetsFetching(cid) && !Tweet.isTweetsLoaded(cid)) {
        refreshControl.beginRefreshing()
      }
      
      tableView.reloadData()
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillAppear(animated)
    disposeBag = DisposeBag()
  }
  
  func refresh(sender: AnyObject) {
    refreshControl.beginRefreshing()
    Store.sharedInstance.dispatch(loadTweetsWithCollectionId: TweetState.homeCollectionId)
  }
}

// MARK: - Data source

extension TimelineViewController: UITableViewDataSource, UITableViewDelegate, TweetTableViewCellDelegate {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tweets.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let tweetCell = tableView.dequeueReusableCellWithIdentifier("tweetCell") as! TweetTableViewCell
    
    tweetCell.tweet = tweets[indexPath.row]
    tweetCell.delegate = self
    if indexPath.row >= tweets.count - 10 {
      Store.sharedInstance.dispatch(loadTweetsWithCollectionId: TweetState.homeCollectionId, more: true)
    }
    
    return tweetCell
  }
  
  func tweetCell(replyToTweetInCell cell: TweetTableViewCell) {
    performSegueWithIdentifier("replySegue", sender: cell)
  }
}

// MARK: - Navigation

extension TimelineViewController {
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "showDetailSegue") {
      (segue.destinationViewController as! TweetDetailViewController).tweet =
        (sender as! TweetTableViewCell).tweet
    }
    
    if (segue.identifier == "replySegue") {
      print(segue.destinationViewController)
      (segue.destinationViewController as! TweetComposeViewController).tweetToReply =
        (sender as! TweetTableViewCell).tweet
    }
  }
}