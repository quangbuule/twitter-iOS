//
//  User.swift
//  twitter
//
//  Created by Lê Quang Bửu on 11/29/15.
//  Copyright © 2015 Lê Quang Bửu. All rights reserved.
//

import Foundation
import RxSwift

struct UserState {
  var id: String = ""
  var name: String = ""
  var screenName: String = ""
  var profileImageURLString: String = ""
  var logedIn: Bool = false
}

extension Store {
  func handleAuthCallback(userId userId: String, userScreenName: String) {
    var User = state.User
    
    User.id = userId
    User.screenName = userScreenName
    
    state.User = User
  }
  
  func getCurrentUser() -> Disposable {
    return TwitterClient.sharedInstance.get("/users/lookup.json", parameters: ["user_id": state.User.id], usingCache: true)
      .subscribeNext { rawData in
        var User = self.state.User
        let userRawData = (rawData as! [NSDictionary])[0]
        
        User.name = userRawData["name"] as! String
        User.profileImageURLString = TwitterClient.getOriginalImageURLString(userRawData["profile_image_url_https"] as? String ?? "")
        User.logedIn = true
        
        self.state.User = User
    }
  }
}