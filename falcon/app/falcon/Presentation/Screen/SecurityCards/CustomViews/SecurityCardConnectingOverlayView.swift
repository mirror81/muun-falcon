//
//  SecurityCardConnectingOverlayView.swift
//  falcon
//
//  Created by Federico Jordán on 20/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

/// Full-screen overlay shown when entering a provider flow for the first time.
/// Displays a spinner and "Connecting to {provider}" message, then fades out
/// when `dismiss(completion:)` is called.
final class SecurityCardConnectingOverlayView: UIView {

    private enum Constants {
        static let haloHeight: CGFloat = 220
        static let dismissAnimationDuration: TimeInterval = 0.25
    }

    private let haloView = SecurityCardGradientHaloView()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = MuunTheme.Color.Surface.background
        setupHalo()
        setupContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Layout

    private func setupHalo() {
        haloView.translatesAutoresizingMaskIntoConstraints = false
        haloView.isUserInteractionEnabled = false
        addSubview(haloView)
        NSLayoutConstraint.activate([
            haloView.topAnchor.constraint(equalTo: topAnchor),
            haloView.leadingAnchor.constraint(equalTo: leadingAnchor),
            haloView.trailingAnchor.constraint(equalTo: trailingAnchor),
            haloView.heightAnchor.constraint(equalToConstant: Constants.haloHeight)
        ])
    }

    private func setupContent() {
        let stack = UIStackView(arrangedSubviews: [spinner, messageLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = MuunTheme.Spacing.xl3
        stack.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = MuunTheme.Font.Body.md

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            stack.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            )
        ])
    }

    // MARK: - Public API

    /// Adds this overlay to `parent` and starts the connecting animation. The
    /// caller controls when to dismiss via `dismiss(completion:)`.
    func show(in parent: UIView, providerName: String, color: UIColor) {
        frame = parent.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parent.addSubview(self)

        haloView.configure(
            haloColor: color,
            backgroundColor: MuunTheme.Color.Surface.background
        )
        spinner.color = color
        spinner.startAnimating()
        messageLabel.attributedText = connectingText(providerName: providerName, color: color)
    }

    /// Fades out and removes the overlay from its superview.
    func dismiss(completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: Constants.dismissAnimationDuration,
            animations: { [weak self] in self?.alpha = 0 },
            completion: { [weak self] _ in
                self?.removeFromSuperview()
                completion()
            }
        )
    }

    // MARK: - Helpers

    private func connectingText(providerName: String, color: UIColor) -> NSAttributedString {
        let template = L10n.SecurityCardConnectingOverlayView.connectingTo(providerName)
        let attributed = NSMutableAttributedString(
            string: template,
            attributes: [.foregroundColor: MuunTheme.Color.Text.bodyPrimary]
        )
        if let providerRange = template.range(of: providerName) {
            let nsRange = NSRange(providerRange, in: template)
            attributed.addAttributes(
                [
                    .foregroundColor: color,
                    .font: Constant.Fonts.system(
                        size: .opTitle,
                        weight: MuunAliases.FontWeight.textStrong
                    )
                ],
                range: nsRange
            )
        }
        return attributed
    }
}
