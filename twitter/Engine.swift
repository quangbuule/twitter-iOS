//
//  Engine.swift
//  twitter
//
//  Created by Lê Quang Bửu on 11/28/15.
//  Copyright © 2015 Lê Quang Bửu. All rights reserved.
//

/**
  Engine store all states of the application
*/

import RxSwift

class Store {
  struct State {
    var Tweet: TweetState = TweetState()
    var User: UserState = UserState()
  }
  
  static var sharedInstance = Store()
  private var observer: AnyObserver<State>!
  var observable: Observable<State>!
  
  init() {
    observable = create { (obs: AnyObserver<State>) -> Disposable in
      self.observer = obs
      return NopDisposable.instance
    }
  }
  
  func withLastState() -> Observable<State> {
    return observable.startWith(state)
  }
  
  private var _state = State()
  
  var state: State {
    get {
      return _state
    }
    
    set (nextState) {
      _state = nextState
      observer?.on(.Next(nextState))
    }
  }
  
  func dispatch(actionType: ActionTypes, payload: Dictionary<String, AnyObject?>) {
    
  }
}