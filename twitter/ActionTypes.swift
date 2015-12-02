//
//  ActionTypes.swift
//  twitter
//
//  Created by Lê Quang Bửu on 12/2/15.
//  Copyright © 2015 Lê Quang Bửu. All rights reserved.
//

enum ActionTypes {
  case loadTweets
  case toggleFavoriteTweets
  case retweet
}

enum AsyncStates {
  case initial
  case success
  case failure
}