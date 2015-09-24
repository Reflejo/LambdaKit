//
//  AVAudioPlayer+ClosureKit.swift
//  Created by Matias Pequeno on 9/23/15.
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
import AVFoundation

public typealias CKDidFinishPlayingClosure = (AVAudioPlayer, Bool) -> Void
public typealias CKDecodeErrorDidOccurClosure = (AVAudioPlayer, NSError?) -> Void

// A global var to produce a unique address for the assoc object handle
private var associatedEventHandle: UInt8 = 0

/**
AVAudioPlayer with closure callback(s).

Example:

```swift
let player = try? AVAudioPlayer(contentsOfURL: soundURL)
player?.play { player, success in
    // deactivate audio session
}
```
*/
extension AVAudioPlayer: AVAudioPlayerDelegate {

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

    /// The closure that fires when a sound has finished playing. This method is NOT called if the player is
    /// stopped due to an interruption.
    public var didFinishPlaying: CKDidFinishPlayingClosure? {
        set { self.closuresWrapper.didFinishPlaying = newValue }
        get { return self.closuresWrapper.didFinishPlaying }
    }

    /// The closure that fires if an error occurs while decoding it will be reported to the delegate.
    public var decodeErrorDidOccur: CKDecodeErrorDidOccurClosure? {
        set { self.closuresWrapper.decodeErrorDidOccur = newValue }
        get { return self.closuresWrapper.decodeErrorDidOccur }
    }

    /**
    Plays a sound asynchronously.

    - parameter didFinishPlaying: Closure to be invoked when audio finishes playing. This won't be invoked if
                                  the player stopped due to an interruption.

    - returns: Returns `true` on success, or `false` on failure.
    */
    public func play(didFinishPlaying closure: CKDidFinishPlayingClosure) -> Bool {
        self.didFinishPlaying = closure
        return self.play()
    }

    // MARK: AVAudioPlayerDelegate implementation

    public func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        self.closuresWrapper.didFinishPlaying?(player, flag)
    }

    public func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        self.closuresWrapper.decodeErrorDidOccur?(player, error)
    }
}

private final class ClosuresWrapper {
    private var didFinishPlaying: CKDidFinishPlayingClosure?
    private var decodeErrorDidOccur: CKDecodeErrorDidOccurClosure?
}
