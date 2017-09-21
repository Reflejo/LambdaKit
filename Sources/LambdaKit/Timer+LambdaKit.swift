//
//  NSTimer+LambdaKit.swift
//  Created by Martin Conte Mac Donell on 3/31/15.
//
//  Copyright (c) 2015 Lyft (http://lyft.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

public typealias LKTimerHandler = (Timer) -> Void

/// Simple closure implementation on NSTimer scheduling.
///
/// Example:
///
/// ```swift
/// NSTimer.scheduledTimerWithTimeInterval(1.0) { timer in
///     print("Did something after 1s!")
/// }
/// ```
extension Timer {

    /// Creates and returns a block-based NSTimer object and schedules it on the current run loop.
    ///
    /// - parameter interval: The number of seconds between firings of the timer.
    /// - parameter repeated: If true, the timer will repeatedly reschedule itself until invalidated. If
    ///                       false, the timer will be invalidated after it fires.
    /// - parameter handler:  The closure that the NSTimer fires.
    ///
    /// - returns: A new NSTimer object, configured according to the specified parameters.
    @discardableResult
    public class func scheduledTimerWithTimeInterval(_ interval: TimeInterval, repeated: Bool = false,
                                                     handler: @escaping LKTimerHandler) -> Timer
    {
        return Timer.scheduledTimer(timeInterval: interval, target: self,
                                    selector: #selector(Timer.invoke(from:)),
                                    userInfo: TimerClosureWrapper(handler: handler, repeats: repeated),
                                    repeats: repeated)
    }

    // MARK: Private methods

    @objc
    private class func invoke(from timer: Timer) {
        if let closureWrapper = timer.userInfo as? TimerClosureWrapper {
            closureWrapper.handler(timer)
        }
    }
}

// MARK: - Private classes

private final class TimerClosureWrapper {
    fileprivate var handler: LKTimerHandler
    private var repeats: Bool

    init(handler: @escaping LKTimerHandler, repeats: Bool) {
        self.handler = handler
        self.repeats = repeats
    }
}
