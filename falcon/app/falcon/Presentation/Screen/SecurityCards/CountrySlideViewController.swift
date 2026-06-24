//
//  CountrySlideViewController.swift
//  falcon
//
//  Created by Federico Jordán on 10/04/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

protocol CountrySlideViewControllerDelegate: AnyObject {
    func countrySlideDidTapSelectCountry()
}

final class CountrySlideViewController: UIViewController {

    private enum Constants {
        static let imageSize: CGFloat = 160
        static let centerYOffset: CGFloat = -10
        static let countryButtonHeight = MuunTheme.Legacy.s52
        static let countryButtonInset = MuunTheme.Spacing.md
        static let countryButtonCornerRadius: CGFloat = 8
        static let chevronSize = MuunTheme.Spacing.md
        static let chevronTextGap = MuunTheme.Spacing.xs
        // Title text needs room for the chevron plus a gap to its right edge.
        static let countryButtonTrailingInset =
            countryButtonInset + chevronSize + chevronTextGap
    }

    private weak var delegate: CountrySlideViewControllerDelegate?
    private let countryButton = UIButton()

    init(delegate: CountrySlideViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func updateCountry(_ country: Country) {
        countryButton.configuration?.title = "\(country.flag) \(country.name)"
        countryButton.configuration?.baseForegroundColor = MuunTheme.Color.Text.bodyPrimary
    }

    // MARK: - Setup

    private func setupView() {
        let imageView = UIImageView(image: Asset.Assets.shield.image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = L10n.CountryOnboardingViewController.title
        titleLabel.textColor = MuunTheme.Color.Text.bodyPrimary
        titleLabel.font = MuunTheme.Font.Heading.h3
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let descriptionLabel = UILabel()
        descriptionLabel.attributedText = L10n.CountryOnboardingViewController.subtitle
            .attributedForDescription(alignment: .center)
        descriptionLabel.numberOfLines = 0

        setupCountryButton()

        let stack = UIStackView(arrangedSubviews: [
            imageView,
            titleLabel,
            descriptionLabel,
            countryButton
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = MuunTheme.Spacing.md
        stack.setCustomSpacing(MuunTheme.Spacing.lg, after: imageView)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),

            titleLabel.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: stack.trailingAnchor),

            descriptionLabel.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: stack.trailingAnchor),

            countryButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            countryButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            countryButton.heightAnchor.constraint(equalToConstant: Constants.countryButtonHeight),

            stack.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: Constants.centerYOffset
            ),
            stack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            stack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            )
        ])
    }

    private func setupCountryButton() {
        var config = UIButton.Configuration.plain()
        config.title = L10n.CountryOnboardingViewController.selectCountry
        config.baseForegroundColor = MuunTheme.Color.Text.bodySecondary
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Constants.countryButtonInset,
            bottom: 0,
            trailing: Constants.countryButtonTrailingInset
        )
        countryButton.configuration = config
        countryButton.contentHorizontalAlignment = .leading
        countryButton.layer.borderWidth = 1
        countryButton.layer.borderColor = MuunTheme.Color.Border.primary.cgColor
        countryButton.layer.cornerRadius = Constants.countryButtonCornerRadius
        countryButton.addTarget(self, action: #selector(didTapSelectCountry), for: .touchUpInside)

        let chevronView = UIImageView(image: UIImage(systemName: "chevron.down"))
        chevronView.tintColor = MuunTheme.Color.Text.bodySecondary
        chevronView.contentMode = .scaleAspectFit
        chevronView.translatesAutoresizingMaskIntoConstraints = false
        chevronView.isUserInteractionEnabled = false
        countryButton.addSubview(chevronView)

        NSLayoutConstraint.activate([
            chevronView.trailingAnchor.constraint(
                equalTo: countryButton.trailingAnchor,
                constant: -Constants.countryButtonInset
            ),
            chevronView.centerYAnchor.constraint(equalTo: countryButton.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: Constants.chevronSize),
            chevronView.heightAnchor.constraint(equalToConstant: Constants.chevronSize)
        ])
    }

    @objc private func didTapSelectCountry() {
        delegate?.countrySlideDidTapSelectCountry()
    }
}
