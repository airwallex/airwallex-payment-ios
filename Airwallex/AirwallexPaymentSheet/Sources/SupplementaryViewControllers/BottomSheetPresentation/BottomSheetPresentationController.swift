//
//  BottomSheetPresentationController.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/3.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class BottomSheetPresentationController: UIPresentationController {

    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
        view.addGestureRecognizer(tap)
        return view
    }()

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView else { return .zero }
        let height = preferredContentHeight(in: containerView)
        return CGRect(
            x: 0,
            y: containerView.bounds.height - height,
            width: containerView.bounds.width,
            height: height
        )
    }

    override func presentationTransitionWillBegin() {
        guard let containerView else { return }
        dimmingView.frame = containerView.bounds
        containerView.insertSubview(dimmingView, at: 0)

        presentedView?.layer.cornerRadius = 16
        presentedView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView?.clipsToBounds = true

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1
            return
        }
        coordinator.animate { _ in
            self.dimmingView.alpha = 1
        }
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0
            return
        }
        coordinator.animate { _ in
            self.dimmingView.alpha = 0
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        dimmingView.frame = containerView?.bounds ?? .zero
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    func updateDimmingAlpha(for progress: CGFloat) {
        dimmingView.alpha = 1 - progress
    }

    @objc private func dimmingViewTapped() {
        presentedViewController.dismiss(animated: true)
    }

    private func preferredContentHeight(in containerView: UIView) -> CGFloat {
        let maxHeight = containerView.bounds.height * 0.6
        let targetSize = CGSize(
            width: containerView.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        let fittingHeight = presentedViewController.view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height + containerView.safeAreaInsets.bottom
        return min(fittingHeight, maxHeight)
    }
}
