//
//  SecurityCardProviderPillView.swift
//  falcon
//
//  Created by Federico Jordán on 28/05/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

protocol SecurityCardProviderPillViewDelegate: AnyObject {
    func securityCardProviderPillViewDidTap(_ view: SecurityCardProviderPillView)
}

/// Rounded pill displaying a provider URL with a globe icon. Mirrors the
/// ProviderPill from the security cards prototype.
final class SecurityCardProviderPillView: UIView {

    private enum Constants {
        static let borderWidth: CGFloat = 1
        static let iconSize: CGFloat = 16
        static let iconSystemName = "globe"
        static let tapHighlightAlpha: CGFloat = 0.6
        static let tapAnimationDuration: TimeInterval = 0.1
    }

    weak var delegate: SecurityCardProviderPillViewDelegate?

    private let iconView = UIImageView(image: UIImage(systemName: Constants.iconSystemName))
    private let urlLabel = UILabel()

    init(url: URL) {
        super.init(frame: .zero)
        setupLayout()
        setupTapGesture()
        configure(url: url)
        setupAccessibility(url: url)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    private func setupLayout() {
        setupAppearance()
        setupContentStack()
    }

    private func setupAppearance() {
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = MuunTheme.Color.Pill.border.cgColor
        backgroundColor = .clear
    }

    private func setupContentStack() {
        iconView.tintColor = MuunTheme.Color.Pill.border
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        urlLabel.font = MuunTheme.Font.Body.sm
        urlLabel.textColor = MuunTheme.Color.Pill.text
        urlLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [iconView, urlLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = MuunTheme.Spacing.xs2
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(
            top: MuunTheme.Spacing.xs,
            left: MuunTheme.Spacing.md,
            bottom: MuunTheme.Spacing.xs,
            right: MuunTheme.Spacing.md
        )
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func configure(url: URL) {
        urlLabel.text = url.host ?? url.absoluteString
    }

    private func setupTapGesture() {
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    private func setupAccessibility(url: URL) {
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = url.host ?? url.absoluteString
        accessibilityHint = L10n.SecurityCardProviderPillView.accessibilityHint
    }

    @objc private func handleTap() {
        UIView.animate(
            withDuration: Constants.tapAnimationDuration,
            animations: { self.alpha = Constants.tapHighlightAlpha },
            completion: { _ in
                UIView.animate(withDuration: Constants.tapAnimationDuration) {
                    self.alpha = 1
                }
            }
        )
        delegate?.securityCardProviderPillViewDidTap(self)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = MuunTheme.Color.Pill.border.cgColor
    }
}
