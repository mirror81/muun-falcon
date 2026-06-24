//
//  SecurityCardMeasurementsView.swift
//  falcon
//
//  Created by Federico Jordán on 20/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class SecurityCardMeasurementsView: UIView {

    private enum Constants {
        static let lineThickness: CGFloat = 1
        static let cardImageScale: CGFloat = 0.85
        // Lines span the full extent of the scaled card image.
        static let heightLineRatio: CGFloat = cardImageScale
        static let widthLineRatio: CGFloat = cardImageScale
        // Inset of the vertical (height) measurement line from the card's left edge.
        static let heightLineLeadingInset = MuunTheme.Spacing.xs
        // Vertical gap between the card image and the horizontal (width) line.
        static let widthLineTopSpacing = MuunTheme.Spacing.xs2
        // Horizontal gap between the height line and its dimension label.
        static let heightLabelGap = MuunTheme.Legacy.s6
        // Length of the end-caps that decorate the measurement lines.
        static let capLength = MuunTheme.Spacing.xs
        static let labelFadeDuration: TimeInterval = 0.05
        static let labelFadeDelay: TimeInterval = 0.3
        static let lineExpandDuration: TimeInterval = 0.18
        static let lineExpandDelay: TimeInterval = 0.2
        static let cardScaleDuration: TimeInterval = 0.2
        static let cardScaleDelay: TimeInterval = 0.15
    }

    private let cardImageView = UIImageView()
    private let heightLineView = UIView()
    private let widthLineView = UIView()
    private let heightDimensionLabel = UILabel()
    private let widthDimensionLabel = UILabel()
    private var caps: [UIView] = []

    private var heightLineConstraint: NSLayoutConstraint!
    private var widthLineConstraint: NSLayoutConstraint!
    private var cardImageHeightConstraint: NSLayoutConstraint?

    private var didAnimate = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        setupCardImage()
        setupHeightRuler()
        setupWidthRuler()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(imageName: String, heightMm: String, widthMm: String, color: UIColor) {
        cardImageView.image = UIImage(named: imageName)
        applyCardImageAspect()
        heightDimensionLabel.text = L10n.SecurityCardFullSpecsViewController.heightFormat(heightMm)
        widthDimensionLabel.text = L10n.SecurityCardFullSpecsViewController.mmFormat(widthMm)
        heightLineView.backgroundColor = color
        widthLineView.backgroundColor = color
        caps.forEach { $0.backgroundColor = color }
    }

    func animateIn() {
        guard !didAnimate else { return }
        didAnimate = true
        layoutIfNeeded()
        let targetHeight = cardImageView.bounds.height * Constants.heightLineRatio
        let targetWidth = cardImageView.bounds.width * Constants.widthLineRatio

        UIView.animate(
            withDuration: Constants.labelFadeDuration,
            delay: Constants.labelFadeDelay
        ) {
            self.heightDimensionLabel.alpha = 1
            self.widthDimensionLabel.alpha = 1
        }

        UIView.animate(
            withDuration: Constants.lineExpandDuration,
            delay: Constants.lineExpandDelay,
            options: .curveEaseOut
        ) {
            self.heightLineView.alpha = 1
            self.widthLineView.alpha = 1
            self.caps.forEach { $0.alpha = 1 }
            self.heightLineConstraint.constant = targetHeight
            self.widthLineConstraint.constant = targetWidth
            self.layoutIfNeeded()
        }

        UIView.animate(
            withDuration: Constants.cardScaleDuration,
            delay: Constants.cardScaleDelay
        ) {
            self.cardImageView.transform = CGAffineTransform(
                scaleX: Constants.cardImageScale,
                y: Constants.cardImageScale
            )
        }
    }

    private func setupCardImage() {
        cardImageView.contentMode = .scaleAspectFit
        cardImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardImageView)
        NSLayoutConstraint.activate([
            cardImageView.topAnchor.constraint(equalTo: topAnchor),
            cardImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    /// Constrains the imageView height to the image's own aspect ratio, so
    /// .scaleAspectFit leaves no empty top/bottom margins (which would let the
    /// measurement lines overshoot the visible card).
    private func applyCardImageAspect() {
        guard let aspect = cardImageView.image.map({ $0.size.width / $0.size.height }) else {
            return
        }
        cardImageHeightConstraint?.isActive = false
        let constraint = cardImageView.heightAnchor.constraint(
            equalTo: cardImageView.widthAnchor,
            multiplier: 1.0 / aspect
        )
        constraint.isActive = true
        cardImageHeightConstraint = constraint
    }

    private func setupHeightRuler() {
        heightLineView.alpha = 0
        heightLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(heightLineView)

        heightLineConstraint = heightLineView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            heightLineView.widthAnchor.constraint(equalToConstant: Constants.lineThickness),
            heightLineView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.heightLineLeadingInset
            ),
            heightLineView.centerYAnchor.constraint(equalTo: cardImageView.centerYAnchor),
            heightLineConstraint
        ])

        heightDimensionLabel.font = Constant.Fonts.system(size: .notice)
        heightDimensionLabel.textColor = MuunTheme.Color.Text.bodySecondary
        heightDimensionLabel.numberOfLines = 2
        heightDimensionLabel.textAlignment = .center
        heightDimensionLabel.alpha = 0
        heightDimensionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(heightDimensionLabel)
        NSLayoutConstraint.activate([
            heightDimensionLabel.trailingAnchor.constraint(
                equalTo: heightLineView.leadingAnchor,
                constant: -Constants.heightLabelGap
            ),
            heightDimensionLabel.centerYAnchor.constraint(equalTo: heightLineView.centerYAnchor)
        ])

        let topCap = makeCap(horizontal: true)
        addSubview(topCap)
        NSLayoutConstraint.activate([
            topCap.centerXAnchor.constraint(equalTo: heightLineView.centerXAnchor),
            topCap.topAnchor.constraint(equalTo: heightLineView.topAnchor)
        ])

        let bottomCap = makeCap(horizontal: true)
        addSubview(bottomCap)
        NSLayoutConstraint.activate([
            bottomCap.centerXAnchor.constraint(equalTo: heightLineView.centerXAnchor),
            bottomCap.bottomAnchor.constraint(equalTo: heightLineView.bottomAnchor)
        ])

        caps += [topCap, bottomCap]
    }

    private func setupWidthRuler() {
        widthLineView.alpha = 0
        widthLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(widthLineView)

        widthLineConstraint = widthLineView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            widthLineView.heightAnchor.constraint(equalToConstant: Constants.lineThickness),
            widthLineView.centerXAnchor.constraint(equalTo: centerXAnchor),
            widthLineView.topAnchor.constraint(
                equalTo: cardImageView.bottomAnchor,
                constant: Constants.widthLineTopSpacing
            ),
            widthLineConstraint
        ])

        widthDimensionLabel.font = Constant.Fonts.system(size: .notice)
        widthDimensionLabel.textColor = MuunTheme.Color.Text.bodySecondary
        widthDimensionLabel.alpha = 0
        widthDimensionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(widthDimensionLabel)
        NSLayoutConstraint.activate([
            widthDimensionLabel.centerXAnchor.constraint(equalTo: widthLineView.centerXAnchor),
            widthDimensionLabel.topAnchor.constraint(
                equalTo: widthLineView.bottomAnchor,
                constant: MuunTheme.Spacing.xs2
            ),
            widthDimensionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let leftCap = makeCap(horizontal: false)
        addSubview(leftCap)
        NSLayoutConstraint.activate([
            leftCap.centerYAnchor.constraint(equalTo: widthLineView.centerYAnchor),
            leftCap.leadingAnchor.constraint(equalTo: widthLineView.leadingAnchor)
        ])

        let rightCap = makeCap(horizontal: false)
        addSubview(rightCap)
        NSLayoutConstraint.activate([
            rightCap.centerYAnchor.constraint(equalTo: widthLineView.centerYAnchor),
            rightCap.trailingAnchor.constraint(equalTo: widthLineView.trailingAnchor)
        ])

        caps += [leftCap, rightCap]
    }

    private func makeCap(horizontal: Bool) -> UIView {
        let cap = UIView()
        cap.alpha = 0
        cap.translatesAutoresizingMaskIntoConstraints = false
        if horizontal {
            cap.widthAnchor.constraint(equalToConstant: Constants.capLength).isActive = true
            cap.heightAnchor.constraint(equalToConstant: Constants.lineThickness).isActive = true
        } else {
            cap.widthAnchor.constraint(equalToConstant: Constants.lineThickness).isActive = true
            cap.heightAnchor.constraint(equalToConstant: Constants.capLength).isActive = true
        }
        return cap
    }
}
