//
//  AVSpeechSynthesizer+ClosureKit.swift
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

public typealias CKDidStartSpeechUtterance = (AVSpeechSynthesizer, AVSpeechUtterance) -> Void
public typealias CKDidFinishSpeechUtterance = (AVSpeechSynthesizer, AVSpeechUtterance) -> Void
public typealias CKDidPauseSpeechUtterance = (AVSpeechSynthesizer, AVSpeechUtterance) -> Void
public typealias CKDidContinueSpeechUtterance = (AVSpeechSynthesizer, AVSpeechUtterance) -> Void
public typealias CKDidCancelSpeechUtterance = (AVSpeechSynthesizer, AVSpeechUtterance) -> Void
public typealias CKWillSpeakRangeOfSpeechString = (AVSpeechSynthesizer, NSRange, AVSpeechUtterance) -> Void

// A global var to produce a unique address for the assoc object handle
private var associatedEventHandle: UInt8 = 0

/**
AVSpeechSynthesizer with closure callback(s).

Example:

```swift
let player = try? AVAudioPlayer(contentsOfURL: soundURL)
player?.play { player, success in
// deactivate audio session
}
```
*/
extension AVSpeechSynthesizer: AVSpeechSynthesizerDelegate {

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

    /// The closure that fires when the synthesizer has begun speaking an utterance.
    public var didStartSpeechUtterance: CKDidStartSpeechUtterance? {
        set { self.closuresWrapper.didStartSpeechUtterance = newValue }
        get { return self.closuresWrapper.didStartSpeechUtterance }
    }

    /// The closure that fires when the synthesizer has finished speaking an utterance.
    public var didFinishSpeechUtterance: CKDidFinishSpeechUtterance? {
        set { self.closuresWrapper.didFinishSpeechUtterance = newValue }
        get { return self.closuresWrapper.didFinishSpeechUtterance }
    }

    /// The closure that fires when the synthesizer has paused while speaking an utterance.
    public var didPauseUtterance: CKDidPauseSpeechUtterance? {
        set { self.closuresWrapper.didPauseSpeechUtterance = newValue }
        get { return self.closuresWrapper.didPauseSpeechUtterance }
    }

    /// The closure that fires when the synthesizer has resumed speaking an utterance after being paused.
    public var didContinueSpeechUtterance: CKDidContinueSpeechUtterance? {
        set { self.closuresWrapper.didContinueSpeechUtterance = newValue }
        get { return self.closuresWrapper.didContinueSpeechUtterance }
    }

    /// The closure that fires when the synthesizer has canceled speaking an utterance.
    public var didCancelSpeechUtterance: CKDidCancelSpeechUtterance? {
        set { self.closuresWrapper.didCancelSpeechUtterance = newValue }
        get { return self.closuresWrapper.didCancelSpeechUtterance }
    }

    /// The closure that fires when the synthesizer is about to speak a portion of an utterance’s text.
    public var willSpeakRangeOfSpeechString: CKWillSpeakRangeOfSpeechString? {
        set { self.closuresWrapper.willSpeakRangeOfSpeechString = newValue }
        get { return self.closuresWrapper.willSpeakRangeOfSpeechString }
    }

    /**
    Enqueues an utterance to be spoken.

    - parameter utterance: An AVSpeechUtterance object containing text to be spoken.
    - parameter closure:   Closure to be called when speech finishes speaking. This won't be called if the
                           synthesizer is paused or canceled.
    */
    public func speakUtterance(utterance: AVSpeechUtterance,
        didFinishUtterance closure: CKDidFinishSpeechUtterance)
    {
        self.didFinishSpeechUtterance = closure
        self.speakUtterance(utterance)
    }

    // MARK: AVSpeechSynthesizerDelegate implementation

    public func speechSynthesizer(synthesizer: AVSpeechSynthesizer,
        didStartSpeechUtterance utterance: AVSpeechUtterance)
    {
        self.closuresWrapper.didStartSpeechUtterance?(synthesizer, utterance)
    }

    public func speechSynthesizer(synthesizer: AVSpeechSynthesizer,
        didFinishSpeechUtterance utterance: AVSpeechUtterance)
    {
        self.closuresWrapper.didFinishSpeechUtterance?(synthesizer, utterance)
    }

    public func speechSynthesizer(synthesizer: AVSpeechSynthesizer,
        didPauseSpeechUtterance utterance: AVSpeechUtterance)
    {
        self.closuresWrapper.didPauseSpeechUtterance?(synthesizer, utterance)
    }

    public func speechSynthesizer(synthesizer: AVSpeechSynthesizer,
        didContinueSpeechUtterance utterance: AVSpeechUtterance)
    {
        self.closuresWrapper.didContinueSpeechUtterance?(synthesizer, utterance)
    }

    public func speechSynthesizer(synthesizer: AVSpeechSynthesizer,
        didCancelSpeechUtterance utterance: AVSpeechUtterance)
    {
        self.closuresWrapper.didCancelSpeechUtterance?(synthesizer, utterance)
    }

    public func speechSynthesizer(synthesizer: AVSpeechSynthesizer,
        willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance)
    {
        self.closuresWrapper.willSpeakRangeOfSpeechString?(synthesizer, characterRange, utterance)
    }
}

private final class ClosuresWrapper {
    private var didStartSpeechUtterance: CKDidStartSpeechUtterance?
    private var didFinishSpeechUtterance: CKDidFinishSpeechUtterance?
    private var didPauseSpeechUtterance: CKDidPauseSpeechUtterance?
    private var didContinueSpeechUtterance: CKDidContinueSpeechUtterance?
    private var didCancelSpeechUtterance: CKDidCancelSpeechUtterance?
    private var willSpeakRangeOfSpeechString: CKWillSpeakRangeOfSpeechString?
}
