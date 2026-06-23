//
//  SecurityCardProviderInfoModal.swift
//  falcon
//
//  Created by Federico Jordán on 01/06/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

/// Modal shown when the user taps the provider URL pill on the security cards
/// flow. Renders a centered info card. The transition
/// (`SecurityCardProviderInfoTransitionController`) animates the card with a
/// scale + translate from the source pill plus a fade.
final class SecurityCardProviderInfoModal: UIViewController {

    private enum Constants {
        static let illustrationAspectRatio: CGFloat = 0.44
        static let illustrationWidth: CGFloat = 165
        static let closeButtonSize: CGFloat = 16
        static let closeButtonHitArea: CGFloat = 32
    }

    private let cardView = UIView()

    private let providerURL: URL
    private let transitioning: SecurityCardProviderInfoTransitionController

    init(providerURL: URL, sourceView: UIView) {
        self.providerURL = providerURL
        self.transitioning = SecurityCardProviderInfoTransitionController(sourceView: sourceView)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = transitioning
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.accessibilityViewIsModal = true
        setupCard()
    }

    private func setupCard() {
        cardView.backgroundColor = MuunTheme.Component.BottomSheet.background
        cardView.layer.cornerRadius = MuunTheme.Component.BottomSheet.cornerRadius
        cardView.clipsToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            cardView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            )
        ])

        setupContent()
    }

    private func setupContent() {
        let illustrationView = makeIllustrationView()
        let bodyView = makeBodyView()

        let stack = UIStackView(arrangedSubviews: [illustrationView, bodyView])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stack)

        let closeButton = makeCloseButton()
        cardView.addSubview(closeButton)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: cardView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            stack.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -MuunTheme.Spacing.xl
            ),

            closeButton.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: MuunTheme.Spacing.sm
            ),
            closeButton.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -MuunTheme.Spacing.sm
            ),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.closeButtonHitArea),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.closeButtonHitArea)
        ])
    }

    private func makeIllustrationView() -> UIView {
        let container = UIView()
        container.backgroundColor = MuunTheme.Component.BottomSheet.illustrationBackground

        let illustration = UIImageView(image: Asset.Assets.connectingWithProvider.image)
        illustration.contentMode = .scaleAspectFit
        illustration.translatesAutoresizingMaskIntoConstraints = false
        illustration.isAccessibilityElement = false
        container.addSubview(illustration)

        let titleLabel = UILabel()
        titleLabel.font = MuunTheme.Font.Body.lg
        titleLabel.textColor = MuunTheme.Color.Text.bodyPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = L10n.SecurityCardProviderInfoModal
            .connectedTo(displayHost(from: providerURL))
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            illustration.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: MuunTheme.Spacing.xl3
            ),
            illustration.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            illustration.widthAnchor.constraint(equalToConstant: Constants.illustrationWidth),
            illustration.heightAnchor.constraint(
                equalTo: illustration.widthAnchor,
                multiplier: Constants.illustrationAspectRatio
            ),

            titleLabel.topAnchor.constraint(
                equalTo: illustration.bottomAnchor,
                constant: MuunTheme.Spacing.md
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -MuunTheme.Spacing.xl3
            )
        ])
        return container
    }

    private func makeBodyView() -> UIView {
        let container = UIView()

        let label = UILabel()
        label.font = MuunTheme.Font.Body.md
        label.textColor = MuunTheme.Color.Text.bodySecondary
        label.numberOfLines = 0
        label.textAlignment = .natural
        label.text = L10n.SecurityCardProviderInfoModal.privacyDisclaimer
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: MuunTheme.Spacing.lg
            ),
            label.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            label.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            ),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func makeCloseButton() -> UIButton {
        let button = UIButton(type: .system)
        let symbolConfig = UIImage.SymbolConfiguration(
            pointSize: Constants.closeButtonSize, weight: .regular
        )
        button.setImage(
            UIImage(systemName: "xmark", withConfiguration: symbolConfig),
            for: .normal
        )
        button.tintColor = MuunTheme.Color.Text.bodySecondary
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = L10n.SecurityCardProviderInfoModal.closeAccessibilityLabel
        button.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        return button
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    private func displayHost(from url: URL) -> String {
        url.host ?? url.absoluteString
    }
}

// MARK: - SecurityCardProviderInfoTransitionable

extension SecurityCardProviderInfoModal: SecurityCardProviderInfoTransitionable {
    var transitionTargetView: UIView { cardView }
}
