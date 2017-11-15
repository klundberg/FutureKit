//
//  File.swift
//  FutureKit
//
//  Created by Kevin Lundberg on 11/15/17.
//  Copyright © 2017 Michael Gray. All rights reserved.
//

#if !os(Linux)

import Foundation

class classWithMethodsThatReturnFutures {

    func iReturnAnInt() -> Future<Int> {

        return Future (.immediate) { () -> Int in
            return 5
        }
    }

    func iReturnFive() -> Int {
        return 5
    }
    func iReturnFromBackgroundQueueUsingBlock() -> Future<Int> {
        //
        return Future(.default) {
            self.iReturnFive()
        }
    }

    func iWillUseAPromise() -> Future<Int> {
        let p : Promise<Int> = Promise()

        // let's do some async dispatching of things here:
        DispatchQueue.main.async {
            p.completeWithSuccess(5)
        }

        return p.future

    }

    func iMayFailRandomly() -> Future<[String:Int]>  {
        let p = Promise<[String:Int]>()

        DispatchQueue.main.async {
            let s = arc4random_uniform(3)
            switch s {
            case 0:
                p.completeWithFail(FutureKitError.genericError("failed randomly"))
            case 1:
                p.completeWithCancel()
            default:
                p.completeWithSuccess(["Hi" : 5])
            }
        }
        return p.future
    }

    func iMayFailRandomlyAlso() -> Future<[String:Int]>  {
        return Future(.main) { () -> Completion<[String:Int]> in
            let s = arc4random_uniform(3)
            switch s {
            case 0:
                return .fail(FutureKitError.genericError("Failed Also"))
            case 1:
                return .cancelled
            default:
                return .success(["Hi" : 5])
            }
        }
    }

    func iCopeWithWhatever()  {

        // ALL 3 OF THESE FUNCTIONS BEHAVE THE SAME

        self.iMayFailRandomly().onComplete { (result) -> Completion<Void> in
            switch result {
            case let .success(value):
                NSLog("\(value)")
                return .success(())
            case let .fail(e):
                return .fail(e)
            case .cancelled:
                return .cancelled
            }
            }
            .ignoreFailures()

        self.iMayFailRandomly().onSuccess { (value) -> Completion<Int> in
            return .success(5)
            }.ignoreFailures()


        self.iMayFailRandomly().onSuccess { (value) -> Void in
            NSLog("")
            }.ignoreFailures()


    }

    func iDontReturnValues() -> Future<()> {
        let f = Future(.primary) { () -> Int in
            return 5
        }

        let p = Promise<()>()

        f.onSuccess { (value) -> Void in
            DispatchQueue.main.async {
                p.completeWithSuccess(())
            }
            }.ignoreFailures()
        // let's do some async dispatching of things here:
        return p.future
    }

    func imGonnaMapAVoidToAnInt() -> Future<Int> {

        let x = self.iDontReturnValues()
            .onSuccess { _ -> Void in
                NSLog("do stuff")
            }.onSuccess { _ -> Int in
                return 5
            }.onSuccess(.primary) { fffive in
                Float(fffive + 10)
        }
        return x.onSuccess {
            Int($0) + 5
        }

    }

    func adding5To5Makes10() -> Future<Int> {
        return self.imGonnaMapAVoidToAnInt().onSuccess { (value) in
            return value + 5
        }
    }

    func convertNumbersToString() -> Future<String> {
        return self.imGonnaMapAVoidToAnInt().onSuccess {
            return "\($0)"
        }
    }

    func convertingAFuture() -> Future<NSString> {
        let f = convertNumbersToString()
        return f.mapAs()
    }


    func testing() {
        _ = Future<Optional<Int>>(success: 5)

        //        let yx = convertOptionalFutures(x)

        //        let y : Future<Int64?> = convertOptionalFutures(x)


    }


}

#endif

