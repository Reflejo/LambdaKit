//
//  MFMessageComposeViewController+LambdaKit.swift
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

public typealias LKMessageComposerHandler = (MFMessageComposeViewController, MessageComposeResult) -> Void

// A global var to produce a unique address for the assoc object handle
private var associatedEventHandle: UInt8 = 0

/// MFMessageComposeViewController with closure callback.
///
/// Note that when setting a completion handler, you don't have the responsability to dismiss the view
/// controller anymore.
///
/// Example:
///
/// ```swift let
/// composeViewController = MFMessageComposeViewController { viewController, result in
///     print("Done")
/// }
/// composerViewController.body = "test sms"
/// ```
///
/// WARNING: You cannot use closures *and* set a delegate at the same time. Setting a delegate will prevent
/// closures for being called and setting a closure will overwrite the delegate property.
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

    private var completionAfterDismissal: Bool {
        get {
            return objc_getAssociatedObject(self, &associatedEventHandle) as? Bool ?? false
        }

        set {
            objc_setAssociatedObject(self, &associatedEventHandle, newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Creates an instance of MFMessageComposeViewController and sets the completion closure to be used
    /// instead of the delegate. This closure is an analog for the
    /// messageComposeViewController:didFinishWithResult: method.
    ///
    /// - parameter completionAfterDismissal: Whether to invoke the completion closure before or
    ///                                       after the controller has been dismissed.
    /// - parameter completion:               A closure analog to
    ///                                       messageComposeViewController:didFinishWithResult:.
    ///                                       If completionAfterDismissal = true, this is invoked after the dismissal animation has completed.
    ///                                       If completionAfterDismissal is false, this is invoked immediately after the call to dismiss the controller.
    ///
    /// - returns: An initialized instance of MFMessageComposeViewController.
    public convenience init(
        completionAfterDismissal: Bool = false,
        completion: @escaping LKMessageComposerHandler)
    {
        self.init()

        self.completionAfterDismissal = completionAfterDismissal
        self.closureWrapper = ClosureWrapper(handler: completion)
        self.messageComposeDelegate = self
    }

    // MARK: MFMessageComposeViewControllerDelegate implementation

    public func messageComposeViewController(_ controller: MFMessageComposeViewController,
        didFinishWith result: MessageComposeResult)
    {
        let completion = {
            self.closureWrapper?.handler(controller, result)
            self.messageComposeDelegate = nil
            self.closureWrapper = nil
        }

        if self.completionAfterDismissal {
            controller.dismiss(animated: true, completion: completion)
        } else {
            controller.dismiss(animated: true)
            completion()
        }
    }
}

// MARK: - Private classes

fileprivate final class ClosureWrapper {
    fileprivate var handler: LKMessageComposerHandler

    fileprivate init(handler: @escaping LKMessageComposerHandler) {
        self.handler = handler
    }
}
