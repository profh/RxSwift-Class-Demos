import RxSwift
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true


//# Initial basic examples
//example(of: "just, of, from") {
//
//  // 1
//  let one = 1
//  let two = 2
//  let three = 3
//
//  // 2
//  let observable1: Observable<Int> = Observable<Int>.just(one)
//  let observable2 = Observable.of(one, two, three)
//  let observable3 = Observable.of([one, two, three])
//  let observable4 = Observable.from([one, two, three])
//}
//sectionBreak()
//
//
////# Subscribing to an observable and printing elements for each event
//example(of: "subscribe") {
//
//  let one = 1
//  let two = 2
//  let three = 3
//
////  let observable = Observable.of(one, two, three)
////  let observable = Observable.of([one, two, three])
////  let observable = Observable.from([one, two, three])
//   let observable = Observable<Int>.just(one)
//
//  //# printing out each event...
//   observable.subscribe { event in
//    print(event)
//   }
//
//  //# but what we really want is the elements, not the events...
////    observable.subscribe { event in
////      if let element = event.element {
////        print(element)
////      }
////    }
//
//  //# however, because this so common, we can just use onNext to write:
//  observable.subscribe(onNext: { element in
//    print(element)
//  })
//}
//sectionBreak()
//
//
////# Creating an empty observable
////# useful when you want to return an observable that immediately terminates, or intentionally has zero values
//example(of: "empty") {
//
//  let observable = Observable<Void>.empty()
//
//  observable
//    .subscribe(
//
//      // just like before...
//      onNext: { element in
//        print(element)
//    },
//
//      // since the .completed event does not include an element, just print a message
//      onCompleted: {
//        print("Completed")
//    }
//  )
//}
//sectionBreak()
//
//
////# Creating the indefinite data stream that never terminates
//example(of: "never") {
//
//  let observable = Observable<Any>.never()
//  observable
//    .subscribe(
//      onNext: { element in
//        print(element)
//    },
//      onCompleted: {
//        print("Completed")
//    }
//  )
//}
//sectionBreak()
//
//
////# Creating an observable from a range
//example(of: "range") {
//
//  let observable = Observable<Int>.range(start: 1, count: 10)
//  observable
//    .subscribe(onNext: { i in
//      let n = Double(i)
//      let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) /
//        2.23606).rounded())
//      print(fibonacci)
//    })
//}
//sectionBreak()
//
//
////# Getting rid of an observable that has finished
//example(of: "dispose") {
//
//  let observable = Observable.of("A", "B", "C")
//
//  // subscribe to the observable, saving as a local constant called
//  // subscription and then print it out
//  let subscription = observable.subscribe { event in
//    print(event)
//  }
//
//  // explicitly cancel a subscription and stop it from emitting any more events
//  subscription.dispose()
//}
//sectionBreak()
//
//
////# Managing each subscription individually would be tedious, so RxSwift includes a DisposeBag type. A dispose bag holds disposables — typically added using the .disposed(by:) method — and will call dispose() on each one when the dispose bag is about to be deallocated.
//
//example(of: "DisposeBag") {
//
//  let disposeBag = DisposeBag()
//
//  Observable.of("A", "B", "C")
//    .subscribe {
//      print($0)
//      // note here we are printing out the emitted event using the default
//      // argument name $0 rather than explicitly defining an argument name
//    }
//    .disposed(by: disposeBag)
//    // and add the return value from subscribe to the disposeBag
//}
//sectionBreak()
//
//
////# We can also specify all events that an observable will emit to subscribers
////# is by using the create operator
//example(of: "create") {
//
//  enum MyError: Error {
//    case anError
//  }
//
//  let disposeBag = DisposeBag()
//
//  Observable<String>.create { observer in
//
//    observer.onNext("1")
////    observer.onError(MyError.anError)
////    observer.onCompleted()
//    observer.onNext("?")
//
//    // the subscribe operators return a disposable representing the subscription, so
//    // we are creating an empty disposable to cover our bases
//    return Disposables.create()
//
//    }
//    .subscribe(
//      onNext: { print($0) },
//      onError: { print($0) },
//      onCompleted: { print("Completed") },
//      onDisposed: { print("Disposed") }
//    )
//    .disposed(by: disposeBag)
//}
//sectionBreak()
//
//
////#  Creating observable factories with the deferred operator
//example(of: "deferred") {
//
//  let disposeBag = DisposeBag()
//
//  // a simple boolean to tell us which observable to return
//  var flip = false
//
//  // creating an observable factory with the deferred operator
//  let factory: Observable<Int> = Observable.deferred {
//
//    // alternate each time a new factory is created
//    flip = !flip
//
//    if flip {
//      return Observable.of(1, 3, 5)  // odd observables
//    } else {
//      return Observable.of(2, 4, 6)  // even observables
//    }
//  }
//
//  for _ in 0...5 {
//    factory.subscribe(onNext: {
//      print($0, terminator: "")
//    })
//      .disposed(by: disposeBag)
//
//    print()
//  }
//}
//sectionBreak()


//# An example of the Single trait used to read a file
example(of: "Traits: Single") {

  let disposeBag = DisposeBag()

  enum FileReadError: Error {
    case fileNotFound, unreadable, encodingFailed
  }

  // create a function that will read a text file and return it as a Single
  func loadText(from filename: String) -> Single<String> {
    // now create the Single
    return Single.create { single in
      // the subscribe closure of the create method must return a disposable
      // so create one now that will be returned in various situations below
      let disposable = Disposables.create()

      // get the path for the filename, or else add a file not found error onto
      // the Single and return the disposable created above
      guard let path = Bundle.main.path(forResource: filename, ofType: "txt") else {
        single(.error(FileReadError.fileNotFound))
        return disposable
      }

      // get the data from the file at that path, or add an unreadable error onto
      // the Single and return the disposable created above
      guard let data = FileManager.default.contents(atPath: path) else {
        single(.error(FileReadError.unreadable))
        return disposable
      }

      // convert the data to a string; otherwise, add an encoding failed error onto
      // the Single and return the disposable created above
      guard let contents = String(data: data, encoding: .utf8) else {
        single(.error(FileReadError.encodingFailed))
        return disposable
      }

      // if we got this far, add contents as a success...
      single(.success(contents))
      // ... and still return the disposable created above
      return disposable
    }
  }

  // Now let's use all this to read a file of HGTTG quotes
  loadText(from: "Quotes")
    .subscribe {
      switch $0 {
      case .success(let string):
        print(string)
      case .error(let error):
        print(error)
      }
    }
    .disposed(by: disposeBag)
}


