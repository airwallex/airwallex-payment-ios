//
//  EmbeddedPaymentView.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 2025/1/5.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

/// A simple view wrapper that embeds a collection view and handles content size updates.
///
/// This view uses `intrinsicContentSize` to automatically update its height based on the
/// collection view's content size, allowing it to work seamlessly with Auto Layout.
class EmbeddedPaymentView: UIView {

    private let collectionView: UICollectionView
    private var contentSizeObservation: NSKeyValueObservation?

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init(frame: .zero)
        setupView()
        setupContentSizeObserver()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        contentSizeObservation?.invalidate()
    }

    private func setupView() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.widthAnchor.constraint(equalToConstant: 375)
                .priority(.fittingSizeLevel + 50)
        ])

        // Disable scrolling since the embedded view is meant to be placed in a scroll view
        collectionView.isScrollEnabled = false
    }

    private func setupContentSizeObserver() {
        contentSizeObservation = collectionView.observe(
            \.contentSize,
            options: [.new, .old]
        ) { [weak self] _, change in
            guard let self else { return }
            // Only invalidate if the content size actually changed
            if change.oldValue != change.newValue {
                self.invalidateIntrinsicContentSize()
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        return collectionView.contentSize
    }
}
