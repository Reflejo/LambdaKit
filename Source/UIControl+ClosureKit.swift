//
//  UIControl+ClosureKit.swift
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

public typealias CKControlHandler = (sender: UIControl) -> Void

// A global var to produce a unique address for the assoc object handle
private var associatedEventHandle: UInt8 = 0

private final class ControlWrapper {
    private var controlEvents: UIControlEvents
    private var handler: CKControlHandler

    init(handler: CKControlHandler, events: UIControlEvents) {
        self.handler = handler
        self.controlEvents = events
    }

    @objc
    private func invoke(control: UIControl) {
        self.handler(sender: control)
    }
}

/** 
Closure control event handling for UIControl.

Example:

```swift
let button = UIButton.buttonWithType(.System) as! UIButton
button.addEventHandler(forControlEvents: .TouchUpInside) { button in
    println("Button touched!!! \(button)")
}
```
*/
extension UIControl {

    private var events: [UInt: [ControlWrapper]]? {
        get {
            return objc_getAssociatedObject(self, &associatedEventHandle) as? [UInt: [ControlWrapper]]
        }

        set {
            objc_setAssociatedObject(self, &associatedEventHandle, newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** 
    Adds a closure for a particular event to an internal dispatch table.

    :param: controlEvents A bitmask specifying the control events for which the action message is sent.
    :param: handler A block representing an action message, with an argument for the sender.
    */
    public func addEventHandler(forControlEvents controlEvents: UIControlEvents, handler: CKControlHandler) {
        let target = ControlWrapper(handler: handler, events: controlEvents)
        self.addTarget(target, action: "invoke:", forControlEvents: controlEvents)

        var events = self.events ?? [:]
        if events[controlEvents.rawValue] == nil {
            events[controlEvents.rawValue] = []
        }

        events[controlEvents.rawValue]!.append(target)
        self.events = events
    }

    /**
    Remove *all* handlers for a given event.

    :param: controlEvents A bitmask specifying the control events for which the handlers will be removed
    */
    public func removeEventHandlers(forControlEvents controlEvents: UIControlEvents? = nil) {
        for (event, wrappers) in self.events ?? [:] {
            if controlEvents != nil && (event & controlEvents!.rawValue != controlEvents!.rawValue) {
                continue
            }

            self.events?[event] = nil
            for wrapper in wrappers {
                self.removeTarget(wrapper, action: "invoke:",
                    forControlEvents: UIControlEvents(rawValue: event))
            }
        }
    }
}
