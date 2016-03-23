//
//  UIBarButtonItem+ClosureKit.swift
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
import UIKit

public typealias CKBarButtonHandler = (sender: UIBarButtonItem) -> Void

// A global var to produce a unique address for the assoc object handle
private var associatedEventHandle: UInt8 = 0

/** 
Closure event initialization for UIBarButtonItem.

Example:

```swift
self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .Bordered) { btn in
    println("Button touched!!!!!! \(btn)")
}
```
*/
extension UIBarButtonItem {

    private var closuresWrapper: ClosureWrapper? {
        get {
            return objc_getAssociatedObject(self, &associatedEventHandle) as? ClosureWrapper
        }

        set {
            objc_setAssociatedObject(self, &associatedEventHandle, newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
    Initializes an UIBarButtonItem that will call the given closure when the button is touched.

    :param: image   The item’s image. If nil an image is not displayed.
    :param: style   The style of the item. One of the constants defined in UIBarButtonItemStyle.
    :param: handler The closure which handles button touches.

    :returns: an initialized instance of UIBarButtonItem.
    */
    public convenience init(image: UIImage?, style: UIBarButtonItemStyle, handler: CKBarButtonHandler) {
        self.init(image: image, style: style, target: nil, action: #selector(UIBarButtonItem.handleAction))
        self.closuresWrapper = ClosureWrapper(handler: handler)
        self.target = self
    }

    // MARK: Private methods

    @objc
    private func handleAction() {
        self.closuresWrapper?.handler(sender: self)
    }
}

// MARK: - Private classes

private final class ClosureWrapper {
    private var handler: CKBarButtonHandler

    init(handler: CKBarButtonHandler) {
        self.handler = handler
    }
}