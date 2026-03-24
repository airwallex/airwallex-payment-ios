//
//  BottomSheetInteractiveDismissTransition.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/3.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class BottomSheetInteractiveDismissTransition: UIPercentDrivenInteractiveTransition {

    private(set) var isInteracting = false
    private weak var presentedViewController: UIViewController?
    private weak var presentationController: BottomSheetPresentationController?
    private weak var scrollView: UIScrollView?

    init(presentedViewController: UIViewController, scrollView: UIScrollView? = nil) {
        self.presentedViewController = presentedViewController
        self.scrollView = scrollView
        super.init()

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        presentedViewController.view.addGestureRecognizer(pan)
    }

    func configure(presentationController: BottomSheetPresentationController) {
        self.presentationController = presentationController
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view,
              let presentedViewController else { return }

        let translation = gesture.translation(in: view)
        let viewHeight = presentedViewController.view.frame.height
        guard viewHeight > 0 else { return }
        let progress = max(0, min(translation.y / viewHeight, 1))

        switch gesture.state {
        case .began:
            isInteracting = true
            presentedViewController.dismiss(animated: true)
        case .changed:
            update(progress)
            presentationController?.updateDimmingAlpha(for: progress)
        case .ended, .cancelled:
            isInteracting = false
            let velocity = gesture.velocity(in: view).y
            if progress > 1.0 / 3.0 || velocity > 500 {
                finish()
            } else {
                cancel()
                presentationController?.updateDimmingAlpha(for: 0)
            }
        default:
            isInteracting = false
            cancel()
            presentationController?.updateDimmingAlpha(for: 0)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension BottomSheetInteractiveDismissTransition: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = pan.velocity(in: pan.view)
        // only activate for downward drag when the scroll view is at the top
        guard velocity.y > 0 else { return false }
        if let scrollView {
            return scrollView.contentOffset.y <= -scrollView.adjustedContentInset.top
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        false
    }
}
