//
//  CADisplayLink+LambdaKit.swift
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

public typealias LKDisplayLinkClosure = (_ progress: Double) -> Void

// A global var to produce a unique address for the assoc object handle
private var associatedEventHandle: UInt8 = 0

/// CADisplayLink closures implementation.
///
/// Example:
///
/// ```swift
/// CADisplayLink.runFor(5.0) { progress in
///     println("Awesome \(progress * 100)%")
/// }
/// ```
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

    /// Creates a DisplayLink and add it to the main run loop. The displayLink will execute for the given
    /// duration in seconds.
    ///
    /// - parameter duration: The duration in seconds.
    /// - parameter handler:  The closure to execute for every tick.
    public static func runFor(_ duration: CFTimeInterval,
                              handler: @escaping LKDisplayLinkClosure) -> CADisplayLink
    {
        let displayLink = CADisplayLink(target: self, selector: #selector(CADisplayLink.tick(_:)))

        displayLink.closureWrapper = ClosuresWrapper(handler: handler, duration: duration)
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        return displayLink
    }

    // MARK: Private methods

    @objc
    private static func tick(_ displayLink: CADisplayLink) {
        guard let closureWrapper = displayLink.closureWrapper else {
            return
        }

        if closureWrapper.startTime < .ulpOfOne {
            displayLink.closureWrapper?.startTime = displayLink.timestamp
        }

        let elapsed = displayLink.timestamp - closureWrapper.startTime
        let duration = closureWrapper.duration
        if elapsed >= duration {
            displayLink.closureWrapper = nil
            displayLink.invalidate()
        } else {
            closureWrapper.handler(elapsed / duration)
        }
    }
}

// MARK: - Private classes

fileprivate final class ClosuresWrapper {
    fileprivate var handler: LKDisplayLinkClosure
    fileprivate var duration: CFTimeInterval
    fileprivate var startTime: CFTimeInterval = 0.0

    fileprivate init(handler: @escaping LKDisplayLinkClosure, duration: CFTimeInterval) {
        self.handler = handler
        self.duration = duration
    }
}
