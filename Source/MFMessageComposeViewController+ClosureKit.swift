//
//  MFMessageComposeViewController+ClosureKit.swift
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

import MessageUI

public typealias CKMessageComposerHandler = (MFMessageComposeViewController, MessageComposeResult) -> Void

// A global var to produce a unique address for the assoc object handle
private var associatedEventHandle: UInt8 = 0

/**
MFMessageComposeViewController with closure callback.

Note that when setting a completion handler, you don't have the responsability to dismiss the view controller
anymore.

Example:

```swift
let composeViewController = MFMessageComposeViewController { viewController, result in println("Done") }
composerViewController.body = "test sms"
```

WARNING: You cannot use closures *and* set a delegate at the same time. Setting a delegate will prevent
closures for being called and setting a closure will overwrite the delegate property.
*/

extension MFMessageComposeViewController: MFMessageComposeViewControllerDelegate {

    private var closureWrapper: ClosureWrapper? {
        get {
            return objc_getAssociatedObject(self, &associatedEventHandle) as? ClosureWrapper
        }

        set {
            objc_setAssociatedObject(self, &associatedEventHandle, newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
    Creates an instance of MFMessageComposeViewController and sets the completion closure to be used instead
    of the delegate. This closure is an analog for the messageComposeViewController:didFinishWithResult:
    method.

    :param: completion A closure analog to messageComposeViewController:didFinishWithResult:

    :returns: an initialized instance of MFMessageComposeViewController.
    */
    public convenience init(completion: CKMessageComposerHandler) {
        self.init()

        self.closureWrapper = ClosureWrapper(handler: completion)
        self.messageComposeDelegate = self
    }

    // MARK: MFMessageComposeViewControllerDelegate implementation

    public func messageComposeViewController(controller: MFMessageComposeViewController,
        didFinishWithResult result: MessageComposeResult)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
        self.closureWrapper?.handler(controller, result)
        self.messageComposeDelegate = nil
        self.closureWrapper = nil
    }
}

// MARK: - Private classes

private final class ClosureWrapper {
    private var handler: CKMessageComposerHandler

    init(handler: CKMessageComposerHandler) {
        self.handler = handler
    }
}
