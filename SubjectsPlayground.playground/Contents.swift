import RxSwift
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true


example(of: "PublishSubject") {
  
  let subject = PublishSubject<String>()
  subject.onNext("Is anyone listening?")
  
  let subscriptionOne = subject
    .subscribe(onNext: { string in
      print("subscription 1)", string)
    })
  
  subject.on(.next("1"))
  subject.onNext("2")
  
  let subscriptionTwo = subject
    .subscribe { event in
      print("subscription 2)", event.element ?? event)
  }
  
  subject.onNext("3")
  
  subscriptionOne.dispose()
  
  subject.onNext("4")
  
  // terminate the subject’s observable sequence w/ onCompleted()
  subject.onCompleted()
  
  // add another element onto the subject. This won’t be emitted and
  // printed, though, b/c the subject has already terminated (for now).
  
  // dispose of our subscription b/c we're done
  subscriptionTwo.dispose()
  
  let disposeBag = DisposeBag()
  
  // create a new subscription to the subject, this time adding it to a dispose bag
  subject
    .subscribe {
      print("subscription 3)", $0.element ?? $0)
    }
    .disposed(by: disposeBag)
  
  //  since we've already added the dispose bag, no need to identify the subscription
  //  so above is fine (uncomment code below to see the warning msg)
  //  let subscriptionThree = subject
  //    .subscribe { event in
  //      print("subscription 3)", event.element ?? event)
  //    }
  //    .disposed(by: disposeBag)
  
  subject.onNext("?")
}
sectionBreak()


example(of: "BehaviorSubject") {
  
  // create a new BehaviorSubject instance with initializer taking an initial value
  let subject = BehaviorSubject(value: "Initial value")
  
  subject.onNext("Is anyone listening?")
  
  let subscriptionOne = subject
    .subscribe(onNext: { string in
      print("subscription 1)", string)
    })
  
  subject.on(.next("1"))
  subject.onNext("2")
  
  let subscriptionTwo = subject
    .subscribe { event in
      print("subscription 2)", event.element ?? event)
  }
  
  subject.onNext("3")
  
  subscriptionOne.dispose()
  
  subject.onNext("4")
  
  // terminate the subject’s observable sequence w/ onCompleted()
  subject.onCompleted()
  
  // dispose of our subscription b/c we're done
  subscriptionTwo.dispose()
  
  let disposeBag = DisposeBag()
  
  subject
    .subscribe {
      print("subscription 3)", $0.element ?? $0)
    }
    .disposed(by: disposeBag)
}
sectionBreak()


example(of: "ReplaySubject") {
  
  let subject = ReplaySubject<String>.create(bufferSize: 2)
  
  subject.onNext("Is anyone listening?")
  
  let subscriptionOne = subject
    .subscribe(onNext: { string in
      print("subscription 1)", string)
    })
  
  subject.on(.next("1"))
  subject.onNext("2")
  
  let subscriptionTwo = subject
    .subscribe { event in
      print("subscription 2)", event.element ?? event)
  }
  
  subject.onNext("3")
  
  subscriptionOne.dispose()
  
  subject.onNext("4")
  
  // terminate the subject’s observable sequence w/ onCompleted()
  subject.onCompleted()
  
  // dispose of our subscription b/c we're done
  subscriptionTwo.dispose()
  
  let disposeBag = DisposeBag()
  
  subject
    .subscribe {
      print("subscription 3)", $0.element ?? $0)
    }
    .disposed(by: disposeBag)
}
sectionBreak()


example(of: "Managing UserSession w/ Variable") {
  
  enum UserSession {
    
    case loggedIn, loggedOut
  }
  
  enum LoginError: Error {
    
    case invalidCredentials
  }
  
  let disposeBag = DisposeBag()
  
  // Create userSession Variable of type UserSession with initial value of .loggedOut
  let userSession = Variable(UserSession.loggedOut)
  
  // Subscribe to receive next events from userSession
  userSession.asObservable()
    .subscribe(onNext: {
      print("userSession changed:", $0)
    })
    .disposed(by: disposeBag)
  
  func logInWith(username: String, password: String, completion: (Error?) -> Void) {
    guard username == "profh@cmu.edu",
      password == "rxswift"
      else {
        completion(LoginError.invalidCredentials)
        return
    }
    
    // Update userSession
    userSession.value = .loggedIn
  }
  
  func logOut() {
    // Update userSession
    userSession.value = .loggedOut
  }
  
  func performActionRequiringLoggedInUser(_ action: () -> Void) {
    // Ensure that userSession is loggedIn and then execute action()
    guard userSession.value == .loggedIn else {
      print("You can't do that!")
      return
    }
    
    action()
  }
  
  for i in 1...5 {
    let password = i % 2 == 0 ? "rxswift" : "password"
    
    logInWith(username: "profh@cmu.edu", password: password) { error in
      guard error == nil else {
        print(error!)
        return
      }
      
      print("User logged in.")
    }
    
    performActionRequiringLoggedInUser {
      print("Successfully did something only a logged in user can do.")
    }
    
    logOut()
  }
}
