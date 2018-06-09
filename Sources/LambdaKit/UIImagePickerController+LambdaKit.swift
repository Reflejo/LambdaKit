//
//  UIImagePickerController+LamdaKit.swift
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

public typealias LKFinishPickingMediaClosure = (UIImagePickerController, [AnyHashable: Any]) -> Void
public typealias LKCancelClosure = (UIImagePickerController) -> Void

// A global var to produce a unique address for the assoc object handle
private var associatedEventHandle: UInt8 = 0

/// UIImagePickerController with closure callback(s).
///
/// Example:
///
/// ```swift
/// let picker = UIImagePickerController()
/// picker.didCancel = { picker in
///     print("DID CANCEL! \(picker)")
/// }
/// picker.didFinishPickingMedia = { picker, media in
///     print("Media: \(media[UIImagePickerControllerEditedImage])")
/// }
/// self.presentViewController(picker, animated: true, completion: nil)
/// ```
extension UIImagePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var closuresWrapper: ClosuresWrapper {
        get {
            if let wrapper = objc_getAssociatedObject(self, &associatedEventHandle) as? ClosuresWrapper {
                return wrapper
            }

            let closuresWrapper = ClosuresWrapper()
            self.closuresWrapper = closuresWrapper
            return closuresWrapper
        }

        set {
            self.delegate = self
            objc_setAssociatedObject(self, &associatedEventHandle, newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// The closure that fires after the receiver finished picking up an image.
    public var didFinishPickingMedia: LKFinishPickingMediaClosure? {
        set { self.closuresWrapper.didFinishPickingMedia = newValue }
        get { return self.closuresWrapper.didFinishPickingMedia }
    }

    /// The closure that fires after the user cancels out of picker.
    public var didCancel: LKCancelClosure? {
        set { self.closuresWrapper.didCancel = newValue }
        get { return self.closuresWrapper.didCancel }
    }

    // MARK: UIImagePickerControllerDelegate implementation

    open func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
    {
        self.closuresWrapper.didFinishPickingMedia?(picker, info)
    }

    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.closuresWrapper.didCancel?(picker)
    }
}

// MARK: - Private classes

fileprivate final class ClosuresWrapper {
    fileprivate var didFinishPickingMedia: LKFinishPickingMediaClosure?
    fileprivate var didCancel: LKCancelClosure?
}
