//
//  UIGestureRecognizer+ClosureKit.swift
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

import UIKit

public typealias CKGestureHandler = (sender: UIGestureRecognizer, state: UIGestureRecognizerState) -> Void

// A global var to produce a unique address for the assoc object handle
private var associatedEventHandle: UInt8 = 0

/**
Closure functionality for UIGestureRecognizer.

Example: 

```swift
let doubleTap = UITapGestureRecognizer { gesture, state in
    println("Double tap!")
}
doubleTap.numberOfTapsRequired = 2
self.addGestureRecognizer(doubleTap)
```
*/
extension UIGestureRecognizer {

    private var closureWrapper: GestureClosureWrapper? {
        get {
            return objc_getAssociatedObject(self, &associatedEventHandle) as? GestureClosureWrapper
        }

        set {
            objc_setAssociatedObject(self, &associatedEventHandle, newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
    Initializes an allocated gesture recognizer that will call the given closure when the gesture is 
    recognized.

    An alternative to the designated initializer.

    :param: handler The closure which handles an executed gesture.

    :returns: an initialized instance of a concrete UIGestureRecognizer subclass.
    */
    public convenience init(handler: CKGestureHandler) {
        self.init()

        self.closureWrapper = GestureClosureWrapper(handler: handler)
        self.addTarget(self, action: "handleAction")
    }

    @objc
    private func handleAction() {
        self.closureWrapper?.handler(sender: self, state: self.state)
    }
}

// MARK: - Private classes

private final class GestureClosureWrapper {
    private var handler: CKGestureHandler

    init(handler: CKGestureHandler) {
        self.handler = handler
    }
}
