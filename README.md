# LambdaKit

Closures make code clear and readable. You can write self-contained, small snippets of code instead of having the logic spread throughout your app,  Cocoa is moving slowly to a block/closure approach but there are still a lot of Cocoa libraries (such as UIKit) that don't support Closures. LambdaKit hopes to facilitate this kind of programming by removing some of the annoying - and, in some cases, impeding - limits on coding with closures.

## Requirements

 * iOS 8.0+
 * Xcode 7.3

## Installation

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate LambdaKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'LambdaKit'
```

Then, run the following command:

```bash
$ pod install
```

## Usage

### UIControl

Closure control event handling for UIControl

```swift
let button = UIButton.buttonWithType(.System) as! UIButton
button.addEventHandler(forControlEvents: .TouchUpInside) { button in
    println("Button touched!!! \(button)")
}
```

### UIGestureRecognizer

Closure functionality for UIGestureRecognizer.

```swift
let doubleTap = UITapGestureRecognizer { gesture, state in
    println("Double tap!")
}
doubleTap.numberOfTapsRequired = 2
self.addGestureRecognizer(doubleTap)
```

### WKWebView

Closure support for WKWebView navigation and UI delegates.

```swift
let webView = WKWebView()

webView.didStartProvisionalNavigation = { webview in
    print("didStartProvisionalNavigation: \(webview)")
}

webView.didFinish = { webview in
    print("didFinish \(webview)")
}

webView.didFailProvisionalNavigation = { webview, error in
    print("didFailProvisionalNavigation with error \(error)")
}

webView.didFail = { webView, error in
    print("didFail with error \(error)")
}

webView.didReceiveChallenge = { webView, challenge, completion in
    completion(.useCredential, URLCredential(trust: ...))
}

webView.shouldPreviewElement = { webview, elementInfo in
    print("shouldPreviewElement \(webview)")
    return true
}

```

### UIImagePickerController

UIImagePickerController with closure callback(s).

```swift
let picker = UIImagePickerController()
picker.didCancel = { picker in
    println("DID CANCEL! \(picker)")
}
picker.didFinishPickingMedia = { picker, media in 
    println("Media: \(media[UIImagePickerControllerEditedImage])")
}
self.presentViewController(picker, animated: true, completion: nil)
```

### NSObject

Closure wrapper for key-value observation.

In Mac OS X Panther, Apple introduced an API called "key-value observing."  It implements an 
[observer pattern](http://en.wikipedia.org/wiki/Observer_pattern), where an object will notify observers of
any changes in state. NSNotification is a rudimentary form of this design style; KVO, however, allows for the
observation of any change in key-value state. The API for key-value observation, however, is flawed, ugly, 
and lengthy.

Like most of the other closure abilities in LambdaKit, observation saves and a bunch of code and a bunch
of potential bugs.

**WARNING**: Observing using closures and cocoa observers are independant. Meaning that you shouldn't
add a "traditional" observer and then remove it using this wrapper nor add a closure observer and remove it
using Cocoa methods.

```swift
self.observeKeyPath("testing", options: .New | .Old) { newValue, oldValue in
    println("Property was: \(oldValue), now is: \(newValue)")
}
```

### MFMailComposeViewController

MFMailComposeViewController with closure callback.

Note that when setting a completion handler, you don't have the responsability to dismiss the view controller
anymore.

```swift
let composeViewController = MFMailComposeViewController { viewController, result, type in println("Done") }
composerViewController.setSubject("Test")
```

### MFMessageComposeViewController

MFMessageComposeViewController with closure callback.

Note that when setting a completion handler, you don't have the responsibility to dismiss the view controller
anymore.

```swift
let composeViewController = MFMessageComposeViewController { viewController, result in println("Done") }
composerViewController.body = "test sms"
```

Set completionAfterDismissal to true if you want the completion handler to be invoked after the controller dismissal animation has been completed.

```
let composeViewController = MFMessageComposeViewController(completionAfterDismissal: true) { viewController, result in println("Done") }
composerViewController.body = "test sms"
```

### UIBarButtonItem

Closure event initialization for UIBarButtonItem.

```swift
self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .Bordered) { btn in
    println("Button touched!!!!!! \(btn)")
}
```

### CADisplayLink

CADisplayLink closures implementation.

```swift
CADisplayLink.runFor(5.0) { progress in
    println("Awesome \(progress * 100)%")
}
```

### CLLocationManager

Closure implementation of CLLocationManager delegate.

Note that when using startUpdatingLocation(handler) you need to use the counterpart `stopUpdatingLocationHandler` or you'll leak memory.

Example:

```swift
let locationManager = CLLocationManager()
locationManager.starUpdatingLocation { location in
    println("Location: \(location)")
}
locationManager.stopUpdatingLocationHandler()
```

### UIActivityItemProvider

Closure implementations for common UIActivityItemProviders.

```swift
let urlProvider = ActivityURLProvider { _, activityType in
    return URL(string: "https://example.com")
}

let activityViewController = UIActivityViewController(activityItems: [urlProvider], applicationActivities: nil)
```

**WARNING: You cannot use closures *and* set a delegate at the same time. Setting a delegate will prevent
closures for being called and setting a closure will overwrite the delegate property.**

## Authors

Martín Conte Mac Donell [@fz](http://twitter.com/fz)
