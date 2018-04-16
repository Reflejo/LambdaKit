//
//  WKWebView+LamdaKit.swift
//  Created by Pau Perez-Martinez on 5/16/18.
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

typealias kDecidePolicyForAction = (WKWebView, WKNavigationAction,
    ((WKNavigationActionPolicy) -> Void)) -> Void
typealias kDecidePolicyForResponse = (WKWebView, WKNavigationResponse,
    ((WKNavigationResponsePolicy) -> Void)) -> Void
typealias kDidStartProvisionalNavigation = (WKWebView, WKNavigation) -> Void
typealias kDidReceiveServerRedirectForProvisionalNavigation = (WKWebView, WKNavigation) -> Void
typealias kDidFailProvisionalNavigation = (WKWebView, WKNavigation, Error) -> Void
typealias kDidCommit = (WKWebView, WKNavigation) -> Void
typealias kDidFinish = (WKWebView, WKNavigation) -> Void
typealias kDidFail = (WKWebView, WKNavigation, Error) -> Void
typealias kDidReceiveChallenge = (WKWebView, URLAuthenticationChallenge,
    ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void)) -> Void
typealias kWebViewContentProcessDidTerminate = (WKWebView) -> Void

// MARK: - WKUIDelegate constants

typealias kCreateWebViewWith = (WKWebView, WKWebViewConfiguration, WKNavigationAction, WKWindowFeatures)
    -> WKWebView?
typealias kWebViewDidClose = (WKWebView) -> Void
typealias kRunJavaScriptAlertPanelWithMessage = (WKWebView, String, WKFrameInfo, (() -> Void)) -> Void
typealias kRunJavaScriptConfirmPanelWithMessage = (WKWebView, String, WKFrameInfo, ((Bool) -> Void)) -> Void
typealias kRunJavaScriptTextInputPanelWithPrompt = (WKWebView, String, String?, WKFrameInfo,
    ((String?) -> Void)) -> Void
typealias kShouldPreviewElement = (WKWebView, WKPreviewElementInfo) -> Bool
typealias kPreviewingViewControllerForElement = (WKWebView, WKPreviewElementInfo, [WKPreviewActionItem])
    -> UIViewController?
typealias kCommitPreviewingViewController = (WKWebView, UIViewController) -> Void

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
            objc_setAssociatedObject(self, &associatedEventHandle, newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - WKNavigationDelegate

extension WKWebView: WKNavigationDelegate {
    /// Decides whether to allow or cancel a navigation.
    var decidePolicyForAction: kDecidePolicyForAction? {
        set { self.closuresWrapper.decidePolicyForAction = newValue }
        get { return self.closuresWrapper.decidePolicyForAction }
    }

    /// Decides whether to allow or cancel a navigation after its response is known.
    var decidePolicyForResponse: kDecidePolicyForResponse? {
        set { self.closuresWrapper.decidePolicyForResponse = newValue }
        get { return self.closuresWrapper.decidePolicyForResponse }
    }

    /// Invoked when a main frame navigation starts.
    var didStartProvisionalNavigation: kDidStartProvisionalNavigation? {
        set { self.closuresWrapper.didStartProvisionalNavigation = newValue }
        get { return self.closuresWrapper.didStartProvisionalNavigation }
    }

    /// Invoked when a server redirect is received for the main frame.
    var didReceiveServerRedirectForProvisionalNavigation: kDidReceiveServerRedirectForProvisionalNavigation? {
        set { self.closuresWrapper.didReceiveServerRedirectForProvisionalNavigation = newValue }
        get { return self.closuresWrapper.didReceiveServerRedirectForProvisionalNavigation }
    }

    /// Invoked when an error occurs while starting to load data for the main frame.
    var didFailProvisionalNavigation: kDidFailProvisionalNavigation? {
        set { self.closuresWrapper.didFailProvisionalNavigation = newValue }
        get { return self.closuresWrapper.didFailProvisionalNavigation }
    }

    /// Invoked when content starts arriving for the main frame.
    var didCommit: kDidCommit? {
        set { self.closuresWrapper.didCommit = newValue }
        get { return self.closuresWrapper.didCommit }
    }

    /// Invoked when a main frame navigation completes.
    var didFinish: kDidFinish? {
        set { self.closuresWrapper.didFinish = newValue }
        get { return self.closuresWrapper.didFinish }
    }

    /// Invoked when an error occurs during a committed main frame navigation.
    var didFail: kDidFail? {
        set { self.closuresWrapper.didFail = newValue }
        get { return self.closuresWrapper.didFail }
    }

    /// Invoked when the web view needs to respond to an authentication challenge.
    var didReceiveChallenge: kDidReceiveChallenge? {
        set { self.closuresWrapper.didReceiveChallenge = newValue }
        get { return self.closuresWrapper.didReceiveChallenge }
    }

    /// Invoked when the web view's web content process is terminated.
    var webViewContentProcessDidTerminate: kWebViewContentProcessDidTerminate? {
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

    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation
        navigation: WKNavigation!)
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

    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
                        completionHandler:
        @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
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
    var createWebViewWith: kCreateWebViewWith? {
        set { self.closuresWrapper.createWebViewWith = newValue }
        get { return self.closuresWrapper.createWebViewWith }
    }

    /// Notifies your app that the DOM window object's close() method completed successfully.
    var webViewDidClose: kWebViewDidClose? {
        set { self.closuresWrapper.webViewDidClose = newValue }
        get { return self.closuresWrapper.webViewDidClose }
    }

    /// Displays a JavaScript alert panel.
    var runJavaScriptAlertPanelWithMessage: kRunJavaScriptAlertPanelWithMessage? {
        set { self.closuresWrapper.runJavaScriptAlertPanelWithMessage = newValue }
        get { return self.closuresWrapper.runJavaScriptAlertPanelWithMessage }
    }

    /// Displays a JavaScript confirm panel.
    var runJavaScriptConfirmPanelWithMessage: kRunJavaScriptConfirmPanelWithMessage? {
        set { self.closuresWrapper.runJavaScriptConfirmPanelWithMessage = newValue }
        get { return self.closuresWrapper.runJavaScriptConfirmPanelWithMessage }
    }

    /// Displays a JavaScript text input panel.
    var runJavaScriptTextInputPanelWithPrompt: kRunJavaScriptTextInputPanelWithPrompt? {
        set { self.closuresWrapper.runJavaScriptTextInputPanelWithPrompt = newValue }
        get { return self.closuresWrapper.runJavaScriptTextInputPanelWithPrompt }
    }

    /// Allows your app to determine whether or not the given element should show a preview.
    var shouldPreviewElement: kShouldPreviewElement? {
        set { self.closuresWrapper.shouldPreviewElement = newValue }
        get { return self.closuresWrapper.shouldPreviewElement }
    }

    /// Allows your app to provide a custom view controller to show when the given element is peeked.
    var previewingViewControllerForElement: kPreviewingViewControllerForElement? {
        set { self.closuresWrapper.previewingViewControllerForElement = newValue }
        get { return self.closuresWrapper.previewingViewControllerForElement }
    }

    /// Allows your app to pop to the view controller it created.
    var commitPreviewingViewController: kCommitPreviewingViewController? {
        set { self.closuresWrapper.commitPreviewingViewController = newValue }
        get { return self.closuresWrapper.commitPreviewingViewController }
    }

    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                        for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures)
        -> WKWebView?
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

    public func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo)
        -> Bool
    {
        return self.shouldPreviewElement?(webView, elementInfo) ?? true
    }

    public func webView(_ webView: WKWebView,
                        previewingViewControllerForElement elementInfo: WKPreviewElementInfo,
                        defaultActions previewActions: [WKPreviewActionItem])
        -> UIViewController?
    {
        return self.previewingViewControllerForElement?(webView, elementInfo, previewActions)
    }

    public func webView(_ webView: WKWebView, commitPreviewingViewController
        previewingViewController: UIViewController)
    {
        self.commitPreviewingViewController?(webView, previewingViewController)
    }
}

// MARK: - Private classes

private final class ClosuresWrapper {
    /// WKNavigationDelegate
    fileprivate var decidePolicyForAction: kDecidePolicyForAction?
    fileprivate var decidePolicyForResponse: kDecidePolicyForResponse?
    fileprivate var didStartProvisionalNavigation: kDidStartProvisionalNavigation?
    fileprivate var
    didReceiveServerRedirectForProvisionalNavigation: kDidReceiveServerRedirectForProvisionalNavigation?
    fileprivate var didFailProvisionalNavigation: kDidFailProvisionalNavigation?
    fileprivate var didCommit: kDidCommit?
    fileprivate var didFinish: kDidFinish?
    fileprivate var didFail: kDidFail?
    fileprivate var didReceiveChallenge: kDidReceiveChallenge?
    fileprivate var webViewContentProcessDidTerminate: kWebViewContentProcessDidTerminate?
    /// WKUIDelegate
    fileprivate var createWebViewWith: kCreateWebViewWith?
    fileprivate var webViewDidClose: kWebViewDidClose?
    fileprivate var runJavaScriptAlertPanelWithMessage: kRunJavaScriptAlertPanelWithMessage?
    fileprivate var runJavaScriptConfirmPanelWithMessage: kRunJavaScriptConfirmPanelWithMessage?
    fileprivate var runJavaScriptTextInputPanelWithPrompt: kRunJavaScriptTextInputPanelWithPrompt?
    fileprivate var shouldPreviewElement: kShouldPreviewElement?
    fileprivate var previewingViewControllerForElement: kPreviewingViewControllerForElement?
    fileprivate var commitPreviewingViewController: kCommitPreviewingViewController?
}
