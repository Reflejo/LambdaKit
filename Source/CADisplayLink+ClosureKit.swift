//
//  CADisplayLink+ClosureKit.swift
//  Created by Martin Conte Mac Donell on 4/7/15.
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
import QuartzCore

public typealias CKDisplayLinkClosure = (progress: Double) -> Void

// A global var to produce a unique address for the assoc object handle
private var associatedEventHandle: UInt8 = 0

/**
CADisplayLink closures implementation.

Example:
```swift
CADisplayLink.runFor(5.0) { progress in
    println("Awesome \(progress * 100)%")
}
```
*/
extension CADisplayLink {

    private var closureWrapper: ClosuresWrapper? {
        get {
            return objc_getAssociatedObject(self, &associatedEventHandle) as? ClosuresWrapper
        }

        set {
            objc_setAssociatedObject(self, &associatedEventHandle, newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
    Creates a DisplayLink and add it to the main run loop. The displayLink will execute for the given 
    duration in seconds.

    :param: duration The duration in seconds.
    :param: handler  The closure to execute for every tick
    */
    public class func runFor(duration: CFTimeInterval, handler: CKDisplayLinkClosure) {
        let displayLink = CADisplayLink(target: self, selector: "tick:")

        displayLink.closureWrapper = ClosuresWrapper(handler: handler, duration: duration)
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }

    // MARK: Private methods

    @objc
    class private func tick(displayLink: CADisplayLink) {
        if displayLink.closureWrapper?.startTime < DBL_EPSILON {
            displayLink.closureWrapper?.startTime = displayLink.timestamp
        }

        let elapsed = displayLink.timestamp - displayLink.closureWrapper!.startTime
        let duration = displayLink.closureWrapper!.duration
        if elapsed >= duration {
            displayLink.closureWrapper = nil
            displayLink.invalidate()
        } else {
            displayLink.closureWrapper?.handler(progress: elapsed / duration)
        }
    }
}

// MARK: - Private classes

private final class ClosuresWrapper {
    private var handler: CKDisplayLinkClosure
    private var duration: CFTimeInterval
    private var startTime: CFTimeInterval = 0.0

    init(handler: CKDisplayLinkClosure, duration: CFTimeInterval) {
        self.handler = handler
        self.duration = duration
    }
}