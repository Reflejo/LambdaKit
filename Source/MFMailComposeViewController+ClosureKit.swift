//
//  MFMailComposeViewController+ClosureKit.swift
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

public typealias CKMailComposerHandler = (MFMailComposeViewController, MFMailComposeResult, NSError?) -> Void

// A global var to produce a unique address for the assoc object handle
private var associatedEventHandle: UInt8 = 0

/**
MFMailComposeViewController with closure callback.

Note that when setting a completion handler, you don't have the responsability to dismiss the view controller
anymore.

Example:

```swift
let composeViewController = MFMailComposeViewController { viewController, result, type in println("Done") }
composerViewController.setSubject("Test")
```

WARNING: You cannot use closures *and* set a delegate at the same time. Setting a delegate will prevent
closures for being called and setting a closure will overwrite the delegate property.
*/

extension MFMailComposeViewController: MFMailComposeViewControllerDelegate {

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
    Creates an instance of MFMailComposeViewController and sets the completion closure to be used instead
    of the delegate. This closure is an analog for the
    mailComposeController:didFinishWithResult:error: method of MFMailComposeViewControllerDelegate.
    
    :param: completion A closure analog to mailComposeController:didFinishWithResult:error:

    :returns: an initialized instance of MFMailComposeViewController.
    */
    public convenience init(completion: CKMailComposerHandler) {
        self.init()

        self.closureWrapper = ClosureWrapper(handler: completion)
        self.mailComposeDelegate = self
    }

    // MARK: MFMailComposeViewControllerDelegate implementation


    public func mailComposeController(controller: MFMailComposeViewController,
        didFinishWithResult result: MFMailComposeResult, error: NSError?)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
        self.closureWrapper?.handler(controller, result, error)
        self.mailComposeDelegate = nil
        self.closureWrapper = nil
    }
}

// MARK: - Private Classes

private final class ClosureWrapper {
    private var handler: CKMailComposerHandler

    init(handler: CKMailComposerHandler) {
        self.handler = handler
    }
}
