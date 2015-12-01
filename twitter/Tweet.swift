//
//  Tweet.swift
//  twitter
//
//  Created by Lê Quang Bửu on 11/28/15.
//  Copyright © 2015 Lê Quang Bửu. All rights reserved.
//

import RxSwift
import Dollar
import SwiftMoment

// MARK: - TweetState
struct TweetState {
  static let homeCollectionId = "home-collection"
  
  typealias Collection = RestfulCollection<TweetState.Entity>
  
  struct Entity: RestfulEntity {
    
    var id: String
    var text: String
    var userName: String
    var userScreenName: String
    var userProfileImageURLString: String
    var createdAt: NSDate
    var screenCreatedAt: String {
      get {
        let tweetMoment = moment(createdAt)
        let diff = moment().intervalSince(tweetMoment)
        
        if (diff.days > 1) {
          return tweetMoment.format("MM/dd/yyyy")
          
        } else if (diff.hours >= 1) {
          return String(format: "%dh", arguments: [Int(diff.hours)])
          
        } else if (diff.minutes >= 1) {
          return String(format: "%dm", arguments: [Int(diff.minutes)])
          
        } else {
          return String(format: "%ds", arguments: [Int(diff.seconds)])
        }
      }
    }
    
    var retweeted: Bool = false
    var favorited: Bool = false
    var retweetCount: Int = 0
    var favoriteCount: Int = 0
    
    var retweeterScreenName: String? = nil
    
    init(creating: Bool, id: String, userName: String, userScreenName: String, userProfileImageURLString: String, text: String) {
      self.id = id
      self.userName = userName
      self.userScreenName = userScreenName
      self.userProfileImageURLString = userProfileImageURLString
      self.text = text
      
      createdAt = NSDate()
    }
    
    init(rawData: NSDictionary) {
      id = rawData["id_str"] as! String
      text = rawData["text"] as! String
      userName = rawData.valueForKeyPath("user.name") as! String
      userScreenName = rawData.valueForKeyPath("user.screen_name") as! String

      userProfileImageURLString = TwitterClient.getOriginalImageURLString(rawData.valueForKeyPath("user.profile_image_url_https") as! String)
      createdAt = {() -> NSDate in
        let s = rawData["created_at"] as! String
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        
        return dateFormatter.dateFromString(s)!
      }()
      
      retweeted = rawData["retweeted"] as! Int != 0
      favorited = rawData["favorited"] as! Int != 0
      retweetCount = rawData["retweet_count"] as! Int
      favoriteCount = rawData["favorite_count"] as! Int
      
      if let retweetedStatus = rawData["retweeted_status"] as? NSDictionary {
        var retweetedTweet = TweetState.Entity(rawData: retweetedStatus)
        let retweeterScreenName = userScreenName
        
        retweetedTweet.retweeted = retweetedTweet.retweeted || retweeted
        retweetedTweet.favorited = retweetedTweet.favorited || favorited
        
        self = retweetedTweet
        self.retweeterScreenName = retweeterScreenName
      }
    }
  }
  
  private var entities: [String: TweetState.Entity] = [:]
  private var collections: [String: TweetState.Collection] = [:]
  
  /**
   * Syntactic sugar functions
   */
  func tweet(id: String) -> TweetState.Entity {
    return entities[id]!
  }
  
  func tweets(collectionId: String) -> [TweetState.Entity] {
    return collections[collectionId]!.ids.map { tweet($0) }
  }
  
  func isTweetsFetching(collectionId: String) -> Bool {
    return collections[collectionId]!.fetching
  }
  
  func isTweetsLoaded(collectionId: String) -> Bool {
    return collections[collectionId]!.loaded
  }
}

// MARK: - Actions
extension Store {
  
  func dispatch(loadTweetsWithCollectionId cid: String, more: Bool = false) -> Disposable {
    var collection = state.Tweet.collections[cid] ?? TweetState.Collection(id: cid)
    var parameters: [String: AnyObject] = [:]
    
    
    if (!more) {
      /**
       * Loading the collection for the first time or refreshing it
       */
      collection.fetching = true
      collection.loaded = false
      
    } else {
      /**
      * Loading more entities of the collection
      */
      if (collection.fetching) {
        return NopDisposable.instance
      }
      
      collection.fetching = true
      parameters["since_id"] = collection.ids.last
    }
    
    /**
     * Update store's state, so the ViewController will react by showing
     * loading indicator
     */
    state.Tweet.collections[collection.id] = collection
    
    return TwitterClient.sharedInstance.get("/statuses/home_timeline.json", parameters: parameters)
      .subscribeNext { rawData in
        var Tweet = self.state.Tweet
        var collection = Tweet.collections[cid]!
        
        collection.fetching = false
        
        if let errors = (rawData as? NSDictionary)?.valueForKey("errors") as? [NSDictionary] {
          print(errors)
          return
        }
        
        if (!more) {
          collection.ids = []
        }
        
        (rawData as! [NSDictionary]).forEach {
          let tweet = TweetState.Entity(rawData: $0)
          
          collection.ids += [tweet.id]
          Tweet.entities[tweet.id] = tweet
        }
        
        Tweet.collections[cid] = collection
        
        /**
         * Update store's state when we fetched tweets successfully
         */
        self.state.Tweet = Tweet
    }
    
  }
  
  func toggleFavoritedTweet(id: String) {
    var entity = state.Tweet.entities[id]!
    
    if (!entity.favorited) {
      entity.favorited = true
      entity.favoriteCount += 1
      
    } else {
      entity.favorited = false
      entity.favoriteCount -= 1
    }
    
    state.Tweet.entities[id] = entity
  }
  
  func retweet(var tweet: TweetState.Entity) {
    var Tweet = state.Tweet
    let User = state.User
    var newTweet: TweetState.Entity
    
    tweet.retweeted = true
    tweet.retweetCount++
    
    newTweet = tweet
    newTweet.id = NSUUID().UUIDString
    newTweet.retweeterScreenName = User.screenName
    
    Tweet.entities[tweet.id] = tweet
    Tweet.entities[newTweet.id] = newTweet
    
    if let ids = Tweet.collections[TweetState.homeCollectionId]?.ids {
      Tweet.collections[TweetState.homeCollectionId]?.ids = [newTweet.id] + ids
    }
    
    state.Tweet = Tweet
  }
  
  func tweet(text text: String) {
    var Tweet = state.Tweet
    let User = state.User
    let newTweet = TweetState.Entity(
      creating: true,
      id: NSUUID().UUIDString,
      userName: User.name,
      userScreenName: User.screenName,
      userProfileImageURLString: User.profileImageURLString,
      text: text
    )

    Tweet.entities[newTweet.id] = newTweet
    
    if let ids = Tweet.collections[TweetState.homeCollectionId]?.ids {
      Tweet.collections[TweetState.homeCollectionId]?.ids = [newTweet.id] + ids
    }
    
    state.Tweet = Tweet
  }
}