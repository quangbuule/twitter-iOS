//
//  RestfulCollection.swift
//  yelp
//
//  Created by Lê Quang Bửu on 11/28/15.
//  Copyright © 2015 Lê Quang Bửu. All rights reserved.
//

import Foundation

struct RestfulCollection<T> {
  var id: String
  var fetching: Bool = false
  var loaded: Bool = false
  var ids: [String] = []
  
  init(id: String) {
    self.id = id
  }
}

protocol RestfulEntity {
  init(rawData: NSDictionary)
}
