//
//  CLLocationManager+ClosureKit.swift
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

import CoreLocation

public typealias CKCoreLocationHandler = CLLocation -> Void

// A global var to produce a unique address for the assoc object handle
private var associatedEventHandle: UInt8 = 0

/**
CLLocationManager with closure callback.

Note that when using startUpdatingLocation(handler) you need to use the counterpart
`stopUpdatingLocationHandler` or you'll leak memory.

Example:

```swift
let locationManager = CLLocationManager()
locationManager.starUpdatingLocation { location in
    println("Location: \(location)")
}
locationManager.stopUpdatingLocationHandler()
```

WARNING: You cannot use closures *and* set a delegate at the same time. Setting a delegate will prevent
closures for being called and setting a closure will overwrite the delegate property.
*/

extension CLLocationManager: CLLocationManagerDelegate {

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
    Starts monitoring GPS location changes and call the given closure for each change.

    :param: completion A closure that will be called passing as the first argument the device's location.
    */
    public func startUpdatingLocation(completion: CKCoreLocationHandler) {
        self.closureWrapper = ClosureWrapper(handler: completion)
        self.delegate = self
        self.startUpdatingLocation()
        if let location = self.location {
            completion(location)
        }
    }

    /**
    Stops monitoring GPS location changes and cleanup.
    */
    public func stopUpdatingLocationHandler() {
        self.stopUpdatingLocation()
        self.closureWrapper = nil
        self.delegate = nil
    }

    /**
    Starts monitoring significant location changes and call the given closure for each change.

    :param: completion A closure that will be called passing as the first argument the device's location.
    */
    public func startMonitoringSignificantLocationChanges(completion: CKCoreLocationHandler) {
        self.closureWrapper = ClosureWrapper(handler: completion)
        self.delegate = self
        self.startMonitoringSignificantLocationChanges()
    }

    /**
    Stops monitoring GPS location changes and cleanup.
    */
    public func stopMonitoringSignificantLocationChangesHandler() {
        self.stopMonitoringSignificantLocationChanges()
        self.closureWrapper = nil
        self.delegate = nil
    }

    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let handler = self.closureWrapper?.handler, let location = manager.location {
            handler(location)
        }
    }
}

// MARK: - Private Classes

private final class ClosureWrapper {
    private var handler: CKCoreLocationHandler

    init(handler: CKCoreLocationHandler) {
        self.handler = handler
    }
}
