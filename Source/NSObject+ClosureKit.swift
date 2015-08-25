//
//  NSObject+ClosureKit.swift
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

public typealias CKObserverHandler = (newValue: AnyObject?, oldValue: AnyObject?) -> Void

// A global var to produce a unique address for the assoc object handle
private var associatedEventHandle: UInt8 = 0
private var uniqueObserverContext: UInt8 = 0

/**
Closure wrapper for key-value observation.

In Mac OS X Panther, Apple introduced an API called "key-value observing."  It implements an
[observer pattern](http://en.wikipedia.org/wiki/Observer_pattern), where an object will notify observers of
any changes in state. NSNotification is a rudimentary form of this design style; KVO, however, allows for the
observation of any change in key-value state. The API for key-value observation, however, is flawed, ugly,
and lengthy.

Like most of the other closure abilities in ClosureKit, observation saves and a bunch of code and a bunch
of potential bugs.

**WARNING**: Observing using closures and cocoa observers are independant. Meaning that you shouldn't
add a "traditional" observer and then remove it using this wrapper nor add a closure observer and remove it
using Cocoa methods.

Example:

```swift
self.observeKeyPath("testing", options: .New | .Old) { newValue, oldValue in
    println("Property was: \(oldValue), now is: \(newValue)")
}
```
*/
extension NSObject {

    private var observer: NSObjectObserver? {
        get {
            return objc_getAssociatedObject(self, &associatedEventHandle) as? NSObjectObserver
        }

        set {
            objc_setAssociatedObject(self, &associatedEventHandle, newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
    Adds a closure observer that executes a block upon a state change.

    :param: keyPath The property to observe, relative to the reciever.
    :param: options The NSKeyValueObservingOptions to use.
    :param: token   A unique identifier used to locate the closure for removal.
    :param: handler A closure with no return argument and two parameters: the newValue and oldValue. Note that
                    both are optionals and will be only present if included in the options parameter.

    :returns: a globally unique identifier for removing observation with removeObserver(token:).
    */
    public func observeKeyPath(keyPath: String, options: NSKeyValueObservingOptions = .New,
        token: String? = nil, handler: CKObserverHandler) -> String
    {
        if self.observer == nil {
            self.observer = NSObjectObserver()
        }

        if self.observer?.hasObservers(forKeyPath: keyPath) == false {
            self.addObserver(self.observer!, forKeyPath: keyPath, options: options,
                context: &uniqueObserverContext)
        }

        let token = token ?? NSUUID().UUIDString
        self.observer?.addHandler(handler, forKeyPath: keyPath, token: token)
        return token
    }

    /**
    Removes the closure observer with a certain identifier.

    :param: token A unique key returned by observeKeyPath or the token given when creating the observer.
    */
    public func removeObserver(token: String) {
        if let keyPath = self.observer?.removeHandler(forToken: token)
            where self.observer?.hasObservers(forKeyPath: keyPath) == false
        {
            self.removeObserver(self.observer!, forKeyPath: keyPath, context: &uniqueObserverContext)
        }
    }

    /**
    Remove all registered closure observers for the given keyPath.

    :param: keyPath The property to stop observing, relative to the reciever.
    */
    public func removeAllObservers(forKeyPath keyPath: String? = nil) {
        guard let observer = self.observer else {
            return
        }

        for keyPath in observer.removeAllHandlers(forKeyPath: keyPath) {
            self.removeObserver(observer, forKeyPath: keyPath, context: &uniqueObserverContext)
        }
    }
}

// MARK - Private classes

private final class NSObjectObserver: NSObject {

    private var handlers: [String: [(token: String, handler: CKObserverHandler)]] = [:]

    private func hasObservers(forKeyPath keyPath: String) -> Bool {
        return handlers[keyPath]?.count > 0
    }

    private func addHandler(handler: CKObserverHandler, forKeyPath keyPath: String, token: String) {
        if self.handlers[keyPath] == nil {
            self.handlers[keyPath] = []
        }

        let element = (token: token, handler: handler)
        self.handlers[keyPath]!.append(element)
    }

    private func removeHandler(forToken removeToken: String) -> String? {
        let allHandlers = self.handlers
        for (keyPath, handlers) in allHandlers {
            for (i, tuple) in handlers.enumerate() {
                let (token, _) = tuple

                // If token is found, remove the handler. If there are not more handlers, remove the observer
                if token == removeToken {
                    self.handlers[keyPath]?.removeAtIndex(i)
                    return keyPath
                }
            }
        }

        return nil
    }

    private func removeAllHandlers(forKeyPath removeKeyPath: String? = nil) -> [String] {
        let allKeyPaths = removeKeyPath != nil ? [removeKeyPath!] : Array(self.handlers.keys)

        for keyPath in allKeyPaths {
            self.handlers.removeValueForKey(keyPath)
        }

        return allKeyPaths
    }

    private override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
        change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        guard let keyPath = keyPath else { return }

        for (_, handler) in self.handlers[keyPath] ?? [] {
            handler(newValue: change?[NSKeyValueChangeNewKey], oldValue: change?[NSKeyValueChangeOldKey])
        }
    }
}
