//
//  KeyboardHandler.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Combine

/// adjust scrollview content inset base on keyboard frame and how much they overlap
class KeyboardHandler {
    private weak var scrollView: UIScrollView? = nil
    private var cancellables = Set<AnyCancellable>()
    /// used to restore scrollView to it's original contentInsets when keyboard disappeared
    /// or when handler is disabled
    private var originalContentInsets: UIEdgeInsets? = nil
    
    /// bind scrollView which need to avoid overlap with keyboard
    /// usually you will want to call this in `viewWillAppear`
    /// - Parameter scrollView: scrollView may be overlapped by keyboard
    func startObserving(_ scrollView: UIScrollView) {
        cancellables.removeAll()
        self.scrollView = scrollView
        originalContentInsets = scrollView.contentInset
        
        NotificationCenter.default.publisher(for: UIControl.keyboardWillHideNotification)
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                self.restoreOrignalContentInsets()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIControl.keyboardWillChangeFrameNotification)
            .sink { [weak self] notification in
                guard let self,
                      let scrollView = self.scrollView,
                      let window = scrollView.window,
                      let value = notification.userInfo?[UIControl.keyboardFrameEndUserInfoKey] as? NSValue else {
                    return
                }
                if self.originalContentInsets == nil {
                    self.originalContentInsets = scrollView.contentInset
                }
                
                let minY = value.cgRectValue.minY

                let scrollViewMaxY = scrollView.superview!.convert(scrollView.frame.origin, to: window).y + scrollView.frame.height
                var edgeInsets = scrollView.contentInset
                guard let originalEdgeInsets = self.originalContentInsets,
                      scrollViewMaxY - minY >= originalEdgeInsets.bottom else {
                    return
                }
                edgeInsets.bottom = scrollViewMaxY - minY
                scrollView.contentInset = edgeInsets
            }
            .store(in: &cancellables)
    }
    
    /// unbind reset scrollView to it's original content inset and unbind scrollView
    /// it's typically called in `viewDidDisappear`
    func stopObserving() {
        cancellables.removeAll()
        restoreOrignalContentInsets()
        scrollView = nil
    }
    
    func restoreOrignalContentInsets() {
        guard let originalContentInsets else { return }
        guard let scrollView else {
            self.originalContentInsets = nil
            return
        }
        scrollView.contentInset = originalContentInsets
        self.originalContentInsets = nil
    }
}
