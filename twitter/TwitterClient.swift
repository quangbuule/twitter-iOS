//
//  TwitterClient.swift
//  twitter
//
//  Created by Lê Quang Bửu on 11/26/15.
//  Copyright © 2015 Lê Quang Bửu. All rights reserved.
//

import Alamofire
import OAuthSwift
import RxSwift

// MARK: - Authentication

class TwitterClient {
  
  private static let consumerKey = "MDTdYnFD3UIHjvk8a4USjJI4B"
  private static let consumerSecret = "Zd5TFVaCLHxeT6pg92C316vVRo6QRKfr2JfV8ZV9EHmEtusaVY"
  
  let oauth = OAuth1Swift(
    consumerKey:      TwitterClient.consumerKey,
    consumerSecret:   TwitterClient.consumerSecret,
    requestTokenUrl:  "https://api.twitter.com/oauth/request_token",
    authorizeUrl:     "https://api.twitter.com/oauth/authorize",
    accessTokenUrl:   "https://api.twitter.com/oauth/access_token"
  )
  
  static let sharedInstance = TwitterClient()
  
  private let apiURLPrefix = "https://api.twitter.com/1.1"
  
  var oauthToken: String!
  var oauthTokenSecret: String!
  var userId: String!
  var userScreenName: String!
  
  init() {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    oauthToken = userDefaults.stringForKey("twitter:oauthToken") ?? ""
    oauthTokenSecret = userDefaults.stringForKey("twitter:oauthTokenSecret") ?? ""
    userId = userDefaults.stringForKey("twitter:userId") ?? ""
    userScreenName = userDefaults.stringForKey("twitter:userScreenName") ?? ""
  }
  
  func authorizeIfNeeded(success success: (TwitterClient) -> Void, failure: (NSError) -> Void) {
    if oauthToken != "" && oauthTokenSecret != "" {
      oauth.client = OAuthSwiftClient(
        consumerKey: TwitterClient.consumerKey,
        consumerSecret: TwitterClient.consumerSecret,
        accessToken: oauthToken,
        accessTokenSecret: oauthTokenSecret
      )
      
      return success(self)
    }
    
    oauth.authorizeWithCallbackURL(
      NSURL(string: "tweeter://oauth-callback/twitter")!,
      success: { credential, response, parameters in
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.oauthToken = credential.oauth_token
        self.oauthTokenSecret = credential.oauth_token_secret
        self.userId = parameters["user_id"]
        self.userScreenName = parameters["screen_name"]
        
        userDefaults.setValue(self.oauthToken, forKey: "twitter:oauthToken")
        userDefaults.setValue(self.oauthTokenSecret, forKey: "twitter:oauthTokenSecret")
        userDefaults.setValue(self.userId, forKey: "twitter:userId")
        userDefaults.setValue(self.userScreenName, forKey: "twitter:userScreenName")
        
        success(self)
      },
      
      failure: failure
    )
  }
  
  
  
  static func getOriginalImageURLString(imageURLString: String) -> String {
    let s = imageURLString
    let re = try! NSRegularExpression(pattern: "_normal", options: .CaseInsensitive)

    return re.stringByReplacingMatchesInString(s, options: [], range: NSRange(0...s.utf16.count-1), withTemplate: "")
  }
}

// MARK: - Errors
extension TwitterClient {
  struct Error {
    var code: Int
    var message: String
    
    static func errors(responseRawData: AnyObject?) -> [Error]? {
      if let errors = (responseRawData as? NSDictionary)?.valueForKey("errors") as? [NSDictionary] {
        
        return errors.map { error in
          return Error(code: error["code"] as! Int, message: error["message"] as! String)
        }
      }
      
      return nil
    }
  }
}

// MARK: - Request
extension TwitterClient {
  
  func request(method: Alamofire.Method, path: String, parameters: [String: AnyObject], usingCache: Bool = false) -> Request {
    let URLString = "\(apiURLPrefix)\(path)"
    let headers = oauth.client.credential.makeHeaders(NSURL(string: URLString)!, method: OAuthSwiftHTTPRequest.Method(rawValue: String(method))!, parameters: parameters)
    var request = Alamofire.request(method, URLString, parameters: parameters, encoding: .URL, headers: headers)
    
    if (!usingCache) {
      let mutableRequest = request.request as! NSMutableURLRequest
      
      mutableRequest.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
      request = Alamofire.request(mutableRequest)
    }
    
    return request
  }
  
  func get(path: String, parameters: [String: AnyObject] = [:], usingCache: Bool = false) -> Observable<AnyObject?> {
    return create { observer in
      let request = self.request(.GET, path: path, parameters: parameters, usingCache: usingCache)
        .responseJSON { response in
          if let error = response.result.error {
            return observer.on(.Error(error))
          }
          
          // TODO: Handle twitter errors in response body with TwitterClient.Error type
          observer.on(.Next(response.result.value));
          observer.on(.Completed);
      }
      
      return AnonymousDisposable {
        request.cancel()
      }
    }
  }
}