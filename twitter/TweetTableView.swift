//
//  TweetsTableView.swift
//  twitter
//
//  Created by Lê Quang Bửu on 11/29/15.
//  Copyright © 2015 Lê Quang Bửu. All rights reserved.
//

import UIKit

class TweetTableView: UITableView {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    separatorStyle = .SingleLine
    separatorInset = UIEdgeInsetsZero
    rowHeight = UITableViewAutomaticDimension
    estimatedRowHeight = 100
  }
}
