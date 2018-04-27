//
//  WKWebView+LamdaKit.swift
//  Created by Pau Perez-Martinez on 4/16/18.
//
//  Copyright (c) 2018 Lyft (http://lyft.com)
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
import WebKit

// A global var to produce a unique address for the assoc object handle
private var associatedEventHandle: UInt8 = 0

// MARK: - WKNavigationDelegate constants

public typealias LKDecidePolicyForAction =
    (WKWebView, WKNavigationAction, ((WKNavigationActionPolicy) -> Void)) -> Void
public typealias LKDecidePolicyForResponse =
    (WKWebView, WKNavigationResponse, ((WKNavigationResponsePolicy) -> Void)) -> Void
public typealias LKDidStartProvisionalNavigation = (WKWebView, WKNavigation) -> Void
public typealias LKDidReceiveServerRedirectForProvisionalNavigation = (WKWebView, WKNavigation) -> Void
public typealias LKDidFailProvisionalNavigation = (WKWebView, WKNavigation, Error) -> Void
public typealias LKDidCommit = (WKWebView, WKNavigation) -> Void
public typealias LKDidFinish = (WKWebView, WKNavigation) -> Void
public typealias LKDidFail = (WKWebView, WKNavigation, Error) -> Void
public typealias LKDidReceiveChallenge =
    (WKWebView, URLAuthenticationChallenge, ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void))
    -> Void
public typealias LKWebViewContentProcessDidTerminate = (WKWebView) -> Void

// MARK: - WKUIDelegate constants

public typealias LKCreateWebViewWith =
    (WKWebView, WKWebViewConfiguration, WKNavigationAction, WKWindowFeatures) -> WKWebView?
public typealias LKWebViewDidClose = (WKWebView) -> Void
public typealias LKRunJavaScriptAlertPanelWithMessage = (WKWebView, String, WKFrameInfo, (() -> Void)) -> Void
public typealias LKRunJavaScriptConfirmPanelWithMessage =
    (WKWebView, String, WKFrameInfo, ((Bool) -> Void)) -> Void
public typealias LKRunJavaScriptTextInputPanelWithPrompt =
    (WKWebView, String, String?, WKFrameInfo, ((String?) -> Void)) -> Void
public typealias LKShouldPreviewElement = (WKWebView, WKPreviewElementInfo) -> Bool
public typealias LKPreviewingViewControllerForElement =
    (WKWebView, WKPreviewElementInfo, [WKPreviewActionItem]) -> UIViewController?
public typealias LKCommitPreviewingViewController = (WKWebView, UIViewController) -> Void

// MARK: - WKNavigationDelegate

extension WKWebView {
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
            self.uiDelegate = self
            self.navigationDelegate = self
            objc_setAssociatedObject(self, &associatedEventHandle, newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - WKNavigationDelegate

extension WKWebView: WKNavigationDelegate {
    /// Decides whether to allow or cancel a navigation.
    public var decidePolicyForAction: LKDecidePolicyForAction? {
        set { self.closuresWrapper.decidePolicyForAction = newValue }
        get { return self.closuresWrapper.decidePolicyForAction }
    }

    /// Decides whether to allow or cancel a navigation after its response is known.
    public var decidePolicyForResponse: LKDecidePolicyForResponse? {
        set { self.closuresWrapper.decidePolicyForResponse = newValue }
        get { return self.closuresWrapper.decidePolicyForResponse }
    }

    /// Invoked when a main frame navigation starts.
    public var didStartProvisionalNavigation: LKDidStartProvisionalNavigation? {
        set { self.closuresWrapper.didStartProvisionalNavigation = newValue }
        get { return self.closuresWrapper.didStartProvisionalNavigation }
    }

    /// Invoked when a server redirect is received for the main frame.
    public var didReceiveServerRedirectForProvisionalNavigation: LKDidReceiveServerRedirectForProvisionalNavigation? {
        set { self.closuresWrapper.didReceiveServerRedirectForProvisionalNavigation = newValue }
        get { return self.closuresWrapper.didReceiveServerRedirectForProvisionalNavigation }
    }

    /// Invoked when an error occurs while starting to load data for the main frame.
    public var didFailProvisionalNavigation: LKDidFailProvisionalNavigation? {
        set { self.closuresWrapper.didFailProvisionalNavigation = newValue }
        get { return self.closuresWrapper.didFailProvisionalNavigation }
    }

    /// Invoked when content starts arriving for the main frame.
    public var didCommit: LKDidCommit? {
        set { self.closuresWrapper.didCommit = newValue }
        get { return self.closuresWrapper.didCommit }
    }

    /// Invoked when a main frame navigation completes.
    public var didFinish: LKDidFinish? {
        set { self.closuresWrapper.didFinish = newValue }
        get { return self.closuresWrapper.didFinish }
    }

    /// Invoked when an error occurs during a committed main frame navigation.
    public var didFail: LKDidFail? {
        set { self.closuresWrapper.didFail = newValue }
        get { return self.closuresWrapper.didFail }
    }

    /// Invoked when the web view needs to respond to an authentication challenge.
    public var didReceiveChallenge: LKDidReceiveChallenge? {
        set { self.closuresWrapper.didReceiveChallenge = newValue }
        get { return self.closuresWrapper.didReceiveChallenge }
    }

    /// Invoked when the web view's web content process is terminated.
    public var webViewContentProcessDidTerminate: LKWebViewContentProcessDidTerminate? {
        set { self.closuresWrapper.webViewContentProcessDidTerminate = newValue }
        get { return self.closuresWrapper.webViewContentProcessDidTerminate }
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        if let handler = self.decidePolicyForAction {
            handler(webView, navigationAction, decisionHandler)
        } else {
            decisionHandler(.allow)
        }
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void)
    {
        if let handler = self.decidePolicyForResponse {
            handler(webView, navigationResponse, decisionHandler)
        } else {
            decisionHandler(.allow)
        }
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.didStartProvisionalNavigation?(webView, navigation)
    }

    public func webView(_ webView: WKWebView,
                        didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!)
    {
        self.didReceiveServerRedirectForProvisionalNavigation?(webView, navigation)
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
                        withError error: Error)
    {
        self.didFailProvisionalNavigation?(webView, navigation, error)
    }

    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.didCommit?(webView, navigation)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.didFinish?(webView, navigation)
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.didFail?(webView, navigation, error)
    }

    public func webView(
        _ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        if let handler = self.didReceiveChallenge {
            handler(webView, challenge, completionHandler)
        } else {
            completionHandler(.useCredential, nil)
        }
    }

    public func webViewContentProcessDidTerminate(_ webView: WKWebView) {
        self.webViewContentProcessDidTerminate?(webView)
    }
}

// MARK: - WKUIDelegate

extension WKWebView: WKUIDelegate {
    /// Creates a new web view.
    public var createWebViewWith: LKCreateWebViewWith? {
        set { self.closuresWrapper.createWebViewWith = newValue }
        get { return self.closuresWrapper.createWebViewWith }
    }

    /// Notifies your app that the DOM window object's close() method completed successfully.
    public var webViewDidClose: LKWebViewDidClose? {
        set { self.closuresWrapper.webViewDidClose = newValue }
        get { return self.closuresWrapper.webViewDidClose }
    }

    /// Displays a JavaScript alert panel.
    public var runJavaScriptAlertPanelWithMessage: LKRunJavaScriptAlertPanelWithMessage? {
        set { self.closuresWrapper.runJavaScriptAlertPanelWithMessage = newValue }
        get { return self.closuresWrapper.runJavaScriptAlertPanelWithMessage }
    }

    /// Displays a JavaScript confirm panel.
    public var runJavaScriptConfirmPanelWithMessage: LKRunJavaScriptConfirmPanelWithMessage? {
        set { self.closuresWrapper.runJavaScriptConfirmPanelWithMessage = newValue }
        get { return self.closuresWrapper.runJavaScriptConfirmPanelWithMessage }
    }

    /// Displays a JavaScript text input panel.
    public var runJavaScriptTextInputPanelWithPrompt: LKRunJavaScriptTextInputPanelWithPrompt? {
        set { self.closuresWrapper.runJavaScriptTextInputPanelWithPrompt = newValue }
        get { return self.closuresWrapper.runJavaScriptTextInputPanelWithPrompt }
    }

    /// Allows your app to determine whether or not the given element should show a preview.
    public var shouldPreviewElement: LKShouldPreviewElement? {
        set { self.closuresWrapper.shouldPreviewElement = newValue }
        get { return self.closuresWrapper.shouldPreviewElement }
    }

    /// Allows your app to provide a custom view controller to show when the given element is peeked.
    public var previewingViewControllerForElement: LKPreviewingViewControllerForElement? {
        set { self.closuresWrapper.previewingViewControllerForElement = newValue }
        get { return self.closuresWrapper.previewingViewControllerForElement }
    }

    /// Allows your app to pop to the view controller it created.
    public var commitPreviewingViewController: LKCommitPreviewingViewController? {
        set { self.closuresWrapper.commitPreviewingViewController = newValue }
        get { return self.closuresWrapper.commitPreviewingViewController }
    }

    public func webView(
        _ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView?
    {
        return self.createWebViewWith?(webView, configuration, navigationAction, windowFeatures)
    }

    public func webViewDidClose(_ webView: WKWebView) {
        self.webViewDidClose?(webView)
    }

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                        initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void)
    {
        if let handler = self.runJavaScriptAlertPanelWithMessage {
            handler(webView, message, frame, completionHandler)
        } else {
            completionHandler()
        }
    }

    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
                        initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void)
    {
        if let handler = self.runJavaScriptConfirmPanelWithMessage {
            handler(webView, message, frame, completionHandler)
        } else {
            completionHandler(true)
        }
    }

    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String,
                        defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping (String?) -> Void)
    {
        if let handler = self.runJavaScriptTextInputPanelWithPrompt {
            handler(webView, prompt, defaultText, frame, completionHandler)
        } else {
            completionHandler(nil)
        }
    }

    public func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool
    {
        return self.shouldPreviewElement?(webView, elementInfo) ?? true
    }

    public func webView(_ webView: WKWebView,
                        previewingViewControllerForElement elementInfo: WKPreviewElementInfo,
                        defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController?
    {
        return self.previewingViewControllerForElement?(webView, elementInfo, previewActions)
    }

    public func webView(_ webView: WKWebView,
                        commitPreviewingViewController previewingViewController: UIViewController)
    {
        self.commitPreviewingViewController?(webView, previewingViewController)
    }
}

// MARK: - Private classes

private final class ClosuresWrapper {
    /// WKNavigationDelegate
    var decidePolicyForAction: LKDecidePolicyForAction?
    var decidePolicyForResponse: LKDecidePolicyForResponse?
    var didStartProvisionalNavigation: LKDidStartProvisionalNavigation?
    var didReceiveServerRedirectForProvisionalNavigation: LKDidReceiveServerRedirectForProvisionalNavigation?
    var didFailProvisionalNavigation: LKDidFailProvisionalNavigation?
    var didCommit: LKDidCommit?
    var didFinish: LKDidFinish?
    var didFail: LKDidFail?
    var didReceiveChallenge: LKDidReceiveChallenge?
    var webViewContentProcessDidTerminate: LKWebViewContentProcessDidTerminate?
    /// WKUIDelegate
    var createWebViewWith: LKCreateWebViewWith?
    var webViewDidClose: LKWebViewDidClose?
    var runJavaScriptAlertPanelWithMessage: LKRunJavaScriptAlertPanelWithMessage?
    var runJavaScriptConfirmPanelWithMessage: LKRunJavaScriptConfirmPanelWithMessage?
    var runJavaScriptTextInputPanelWithPrompt: LKRunJavaScriptTextInputPanelWithPrompt?
    var shouldPreviewElement: LKShouldPreviewElement?
    var previewingViewControllerForElement: LKPreviewingViewControllerForElement?
    var commitPreviewingViewController: LKCommitPreviewingViewController?
}
