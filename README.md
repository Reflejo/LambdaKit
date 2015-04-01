# ClosureKit

Closures make code clear and readable. You can write self-contained, small snipets of code instead of having the logic spread throughout your app,  Cocoa is moving slowly to a block/closure approach but there are still a lot of Cocoa libraries (such as UIKit) that don't support Closures. ClosureKit hopes to facilitate this kind of programming by removing some of the annoying - and, in some cases, impeding - limits on coding with closures.

## Requirements

 * iOS 7.0+
 * Xcode 8.3

ClosureKit can 

## Installation

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate ClosureKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'ClosureKit'
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

### UIWebView

Closure support for UIWebView delegate.

```swift
let webView = UIWebView()
webView.shouldStartLoad = { webView, request, type in
    println("shouldStartLoad: \(request)")
    return true
}

webView.didStartLoad = { webView in
    println("didStartLoad: \(webView)")
}

webView.didFinishLoad = { webView in
    println("didFinishLoad \(webView)")
}

webView.didFinishWithError = { webView, error in
    println("didFinishWithError \(error)")
}
```

### NSTimer

Simple closure implementation on NSTimer scheduling.

```swift
NSTimer.scheduledTimerWithTimeInterval(1.0) { timer in
println("Did something after 1s!")
}
```
