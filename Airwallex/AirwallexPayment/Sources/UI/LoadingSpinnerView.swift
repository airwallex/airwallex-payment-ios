//
//  LoadingSpinnerView.swift
//  AirwallexPayment
//
//  Created by Weiping Li on 11/7/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import UIKit
#if canImport(AirwallexCore)
import AirwallexCore
#endif

class LoadingSpinnerView: UIView {
    enum Style {
        case small
        case medium
        case large
        
        var lineWidth: CGFloat {
            switch self {
            case .small: return 2
            case .medium: return 3
            case .large: return 4
            }
        }
        
        var width: CGFloat {
            switch self {
            case .small: return 24
            case .medium: return 36
            case .large: return 48
            }
        }
        
        var height: CGFloat {
            width
        }
        
        var radius: CGFloat {
            (width - lineWidth) / 2
        }
        
        var startAngle: CGFloat {
            -CGFloat.pi / 2
        }
        
        var endAngle: CGFloat {
            startAngle + CGFloat.pi * (2 * 0.3)
        }
    }

    let style: Style

    private let animationKey = "rotation"
    private let shapeLayer = CAShapeLayer()

    init(size: Style) {
        self.style = size
        super.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        commonInit()
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: style.width, height: style.height)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func commonInit() {

        let arcPath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: style.radius,
            startAngle: style.startAngle,
            endAngle: style.endAngle,
            clockwise: true
        )
        shapeLayer.path = arcPath.cgPath

        shapeLayer.lineWidth = style.lineWidth
        shapeLayer.strokeColor = AWXTheme.shared().tintColor.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineCap = .round

        layer.addSublayer(shapeLayer)
        backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if shapeLayer.frame != bounds {
            shapeLayer.frame = bounds
            let arcPath = UIBezierPath(
                arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                radius: style.radius,
                startAngle: style.startAngle,
                endAngle: style.endAngle,
                clockwise: true
            )
            shapeLayer.path = arcPath.cgPath
        }
    }
    
    func startAnimating() {
        guard shapeLayer.animation(forKey: animationKey) == nil else {
            return
        }
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.fromValue = 0
        anim.toValue = 2 * Double.pi
        anim.duration = 1.0
        anim.repeatCount = .infinity
        shapeLayer.add(anim, forKey: animationKey)
        isHidden = false
        alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }

    func stopAnimating() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { _ in
            self.isHidden = true
            self.shapeLayer.removeAnimation(forKey: self.animationKey)
        }
    }
    
    var isAnimating: Bool {
        shapeLayer.animation(forKey: animationKey) != nil && !isHidden
    }
}
