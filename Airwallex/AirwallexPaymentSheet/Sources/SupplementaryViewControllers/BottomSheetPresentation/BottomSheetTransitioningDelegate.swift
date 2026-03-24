//
//  BottomSheetTransitioningDelegate.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/3.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    private let interactiveDismiss: BottomSheetInteractiveDismissTransition

    init(interactiveDismiss: BottomSheetInteractiveDismissTransition) {
        self.interactiveDismiss = interactiveDismiss
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let controller = BottomSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
        interactiveDismiss.configure(presentationController: controller)
        return controller
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        BottomSheetAnimator(isPresenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        BottomSheetAnimator(isPresenting: false)
    }

    func interactionControllerForDismissal(
        using animator: any UIViewControllerAnimatedTransitioning
    ) -> (any UIViewControllerInteractiveTransitioning)? {
        interactiveDismiss.isInteracting ? interactiveDismiss : nil
    }
}
