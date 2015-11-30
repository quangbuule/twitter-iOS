//
//  LandingViewController.swift
//  twitter
//
//  Created by Lê Quang Bửu on 11/27/15.
//  Copyright © 2015 Lê Quang Bửu. All rights reserved.
//

import UIKit
import RxSwift

class LandingViewController: UINavigationController {
  
  var disposeBag = DisposeBag()
  var tweets: [TweetState.Entity] = []
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    navigationBar.barTintColor = Colors.picton
    navigationBar.barStyle = .Black
    navigationBar.tintColor = UIColor.whiteColor()
  }
}
