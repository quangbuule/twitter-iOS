//
//  ViewController.swift
//  twitter
//
//  Created by Lê Quang Bửu on 11/25/15.
//  Copyright © 2015 Lê Quang Bửu. All rights reserved.
//

import UIKit
import RxSwift

class LoginViewController: UIViewController {
  
  var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Colors.picton
  }
  
  @IBAction func handleLoginButtonTap(sender: UIButton) {
    TwitterClient.sharedInstance.authorizeIfNeeded(
      success: { twitterClient in
        Store.sharedInstance.handleAuthCallback(
          userId: twitterClient.userId,
          userScreenName: twitterClient.userScreenName
        )
        Store.sharedInstance.getCurrentUser()
        Store.sharedInstance.withLastState()
          .subscribeNext { state in
            if state.User.logedIn {
              self.performSegueWithIdentifier("landingSegue", sender: nil)
              self.disposeBag = DisposeBag()
            }
        }
        .addDisposableTo(self.disposeBag)
      },
      failure: { error in
      }
    )
  }
}

