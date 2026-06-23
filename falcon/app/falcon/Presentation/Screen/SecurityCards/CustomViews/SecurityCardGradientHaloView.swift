//
//  SecurityCardGradientHaloView.swift
//  falcon
//
//  Created by Federico Jordán on 20/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class SecurityCardGradientHaloView: UIView {

    private enum Constants {
        static let innerAlpha: CGFloat = 0.15
        static let midAlpha: CGFloat = 0.08
        // Pulls the gradient center above the view so the inner peak sits
        // at the very top of the screen and the radial fade stays smooth.
        static let topOffset: CGFloat = -40
    }

    private var haloColor: UIColor = .clear
    private var fadeColor: UIColor = .clear

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentMode = .redraw
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(haloColor: UIColor, backgroundColor: UIColor) {
        self.haloColor = haloColor
        fadeColor = backgroundColor
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let endRadius = rect.height
        guard endRadius > 0 else { return }
        // The first stop tracks topOffset so the brightest ring lands on the
        // view's top edge regardless of the height the caller picks.
        let innerLocation = min(1, abs(Constants.topOffset) / endRadius)
        // Interpolating the last stop toward the page background (instead of
        // the provider color at zero alpha) blends intermediate pixels toward
        // the surface, removing the hard edge at the view's bottom.
        let colors = [
            haloColor.withAlphaComponent(Constants.innerAlpha).cgColor,
            haloColor.withAlphaComponent(Constants.midAlpha).cgColor,
            fadeColor.withAlphaComponent(0).cgColor
        ] as CFArray
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors,
            locations: [innerLocation, 0.5, 1]
        ) else { return }
        let center = CGPoint(x: rect.midX, y: Constants.topOffset)
        context.drawRadialGradient(
            gradient,
            startCenter: center, startRadius: 0,
            endCenter: center, endRadius: endRadius,
            options: []
        )
    }
}
