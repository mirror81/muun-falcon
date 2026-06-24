//
//  BuyDetailsViewController.swift
//  falcon
//
//  Created by Federico Jordán on 13/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class BuyDetailsViewController: MUViewController {

    private enum Constants {
        static let haloHeightPadding = MuunTheme.Legacy.s40
        static let ctaButtonHeight: CGFloat = 50
        static let ctaButtonCornerRadius: CGFloat = 8
        static let ctaButtonImagePadding = MuunTheme.Legacy.s6
    }

    private enum AnimationConstants {
        static let cardSpringDuration: TimeInterval = 0.75
        static let cardSpringDamping: CGFloat = 1.0
        static let contentFadeDuration: TimeInterval = 0.45
        static let contentFadeDelay: TimeInterval = 0.08
        static let priceFooterSlideDuration: TimeInterval = 0.5
    }

    private lazy var presenter = instancePresenter(
        BuyDetailsPresenter.init,
        delegate: self,
        state: .init(provider: provider, card: card)
    )

    private let provider: SecurityCardProvider
    private let card: SecurityCard
    private let initialCardFrame: CGRect?
    private let initialPriceFooterSnapshot: UIView?
    private let initialPriceFooterFrame: CGRect

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let haloView = SecurityCardGradientHaloView()
    private let descriptionLabel = UILabel()
    private let cardImageView = UIImageView()
    private lazy var productListView = SecurityCardProductListView(delegate: self)
    private lazy var fullPriceView = SecurityCardFullPriceView(delegate: self)
    private let ctaButton = UIButton(type: .system)

    private var cardImageHeightConstraint: NSLayoutConstraint?
    private var hasAnimatedEntry = false

    override var screenLoggingName: String {
        "security_cards_buy_details"
    }

    init(
        provider: SecurityCardProvider,
        card: SecurityCard,
        initialCardFrame: CGRect? = nil,
        initialPriceFooterSnapshot: UIView? = nil,
        initialPriceFooterFrame: CGRect = .zero
    ) {
        self.provider = provider
        self.card = card
        self.initialCardFrame = initialCardFrame
        self.initialPriceFooterSnapshot = initialPriceFooterSnapshot
        self.initialPriceFooterFrame = initialPriceFooterFrame
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        additionalSafeAreaInsets = .zero
        navigationController?.navigationBar.prefersLargeTitles = true
        presenter.setUp()
        setupTransparentNavBar()
        hideEntryContentIfNeeded()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        setupHaloView()
        setupScrollView()
        setupHeader()
        setupCardImage()
        setupProductList()
        setupFullPrice()
        setupCTAButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runEntryAnimationIfNeeded()
    }

    private var entryAnimatedViews: [UIView] {
        [haloView, descriptionLabel, productListView, fullPriceView, ctaButton]
    }

    /// Hides the content that will be animated in, and pins the marketplace
    /// price footer snapshot to its source position. Runs early (viewWillAppear)
    /// so the user never sees the cardImageView at its natural (final) position
    /// before the hero animation starts.
    private func hideEntryContentIfNeeded() {
        guard initialCardFrame != nil, !hasAnimatedEntry else { return }
        cardImageView.alpha = 0
        entryAnimatedViews.forEach { $0.alpha = 0 }
        if let snapshot = initialPriceFooterSnapshot {
            snapshot.frame = initialPriceFooterFrame
            view.addSubview(snapshot)
        }
    }

    /// Computes the card transform from its now-final on-screen frame, applies
    /// it, reveals the cardImageView, and animates the hero in. Deferred to
    /// viewDidAppear so Auto Layout has fully settled the cardImageView's
    /// position before we capture it.
    private func runEntryAnimationIfNeeded() {
        guard let initial = initialCardFrame, !hasAnimatedEntry else { return }
        hasAnimatedEntry = true

        view.layoutIfNeeded()
        let finalFrame = cardImageView.convert(cardImageView.bounds, to: nil)
        guard !finalFrame.isEmpty else {
            cardImageView.alpha = 1
            entryAnimatedViews.forEach { $0.alpha = 1 }
            return
        }

        let scale = initial.width / finalFrame.width
        let translateX = initial.midX - finalFrame.midX
        let translateY = initial.midY - finalFrame.midY

        // Order matters: scaledBy first so the subsequent translation lives in
        // unscaled (screen) coordinates. The reverse order applies the scale
        // factor to the translation values too, leaving the card off-position.
        cardImageView.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: translateX, y: translateY)
        cardImageView.alpha = 1

        UIView.animate(
            withDuration: AnimationConstants.cardSpringDuration,
            delay: 0,
            usingSpringWithDamping: AnimationConstants.cardSpringDamping,
            initialSpringVelocity: 0,
            options: [.curveEaseOut]
        ) {
            self.cardImageView.transform = .identity
        }

        UIView.animate(
            withDuration: AnimationConstants.contentFadeDuration,
            delay: AnimationConstants.contentFadeDelay,
            options: [.curveEaseInOut]
        ) {
            self.entryAnimatedViews.forEach { $0.alpha = 1 }
        }

        if let snapshot = initialPriceFooterSnapshot {
            UIView.animate(
                withDuration: AnimationConstants.priceFooterSlideDuration,
                delay: 0,
                options: [.curveEaseIn]
            ) {
                snapshot.transform = CGAffineTransform(
                    translationX: 0,
                    y: snapshot.frame.height
                )
            } completion: { _ in
                snapshot.removeFromSuperview()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.tearDown()
        restoreNavBar()
    }

    // MARK: - Layout

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            // bottom is pinned to separator.topAnchor in setupFullPrice
        ])

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor
                .constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor
                .constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor
                .constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupHaloView() {
        haloView.translatesAutoresizingMaskIntoConstraints = false
        haloView.isUserInteractionEnabled = false
        view.addSubview(haloView)

        let screenWidth = UIScreen.main.bounds.width
        let haloHeight = screenWidth / 2 + Constants.haloHeightPadding

        NSLayoutConstraint.activate([
            haloView.topAnchor.constraint(equalTo: view.topAnchor),
            haloView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            haloView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            haloView.heightAnchor.constraint(equalToConstant: haloHeight)
        ])
    }

    private func setupHeader() {
        descriptionLabel.font = Constant.Fonts.system(size: .opDesc)
        descriptionLabel.textColor = MuunTheme.Color.Text.bodySecondary
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.topAnchor,
                constant: MuunTheme.Spacing.sm
            ),
            descriptionLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            )
        ])
    }

    private func setupCardImage() {
        cardImageView.contentMode = .scaleAspectFit
        cardImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardImageView)

        NSLayoutConstraint.activate([
            cardImageView.topAnchor.constraint(
                equalTo: descriptionLabel.bottomAnchor,
                constant: MuunTheme.Spacing.md
            ),
            cardImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            cardImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            )
        ])
    }

    /// Constrains the imageView height to the image's own aspect ratio, so
    /// .scaleAspectFit leaves no empty top/bottom margins. Called whenever
    /// the image is (re)set in update(viewModel:).
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

    private func setupProductList() {
        productListView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(productListView)

        NSLayoutConstraint.activate([
            productListView.topAnchor.constraint(
                equalTo: cardImageView.bottomAnchor,
                constant: MuunTheme.Spacing.md
            ),
            productListView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            productListView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            ),
            productListView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -MuunTheme.Spacing.xl3
            )
        ])
    }

    private func setupFullPrice() {
        fullPriceView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullPriceView)

        NSLayoutConstraint.activate([
            scrollView.bottomAnchor.constraint(equalTo: fullPriceView.topAnchor),

            fullPriceView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            fullPriceView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            )
        ])
    }

    private func setupCTAButton() {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "globe")
        config.imagePadding = Constants.ctaButtonImagePadding
        config.baseForegroundColor = .white
        config.cornerStyle = .fixed
        config.background.cornerRadius = Constants.ctaButtonCornerRadius
        config
            .titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = Constant.Fonts.system(size: .desc, weight: .semibold)
            return outgoing
        }
        ctaButton.configuration = config
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.addTarget(self, action: #selector(didTapCTA), for: .touchUpInside)
        view.addSubview(ctaButton)

        NSLayoutConstraint.activate([
            ctaButton.topAnchor.constraint(
                equalTo: fullPriceView.bottomAnchor,
                constant: MuunTheme.Spacing.xl3
            ),
            ctaButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            ctaButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            ),
            ctaButton.heightAnchor.constraint(
                equalToConstant: Constants.ctaButtonHeight
            ),
            ctaButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -MuunTheme.Spacing.xl3
            )
        ])
    }

    // MARK: - Actions

    @objc
    private func didTapCTA() {
        let vc = ShippingViewController(provider: provider)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - SecurityCardProductListViewDelegate

extension BuyDetailsViewController: SecurityCardProductListViewDelegate {
    func didTapSeeFullSpecs() {
        let vc = SecurityCardFullSpecsViewController(provider: provider, card: card)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension BuyDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let adjustedOffset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        let translation = -max(0, adjustedOffset)
        haloView.transform = CGAffineTransform(translationX: 0, y: translation)
    }
}

// MARK: - BuyDetailsPresenterDelegate

extension BuyDetailsViewController: BuyDetailsPresenterDelegate {
    func update(viewModel: BuyDetailsViewModel) {
        haloView.configure(
            haloColor: viewModel.providerColor,
            backgroundColor: MuunTheme.Color.Surface.background
        )
        title = viewModel.title
        descriptionLabel.text = viewModel.description
        cardImageView.image = UIImage(named: viewModel.imageName)
        applyCardImageAspect()
        productListView.configure(
            material: viewModel.material,
            shipsFrom: viewModel.shipsFrom,
            deliveryDays: viewModel.deliveryDays,
            providerColor: viewModel.providerColor
        )
        fullPriceView.configure(viewModel: viewModel.priceViewModel)
        ctaButton.configuration?.baseBackgroundColor = viewModel.providerColor
        ctaButton.configuration?.title = viewModel.ctaTitle
    }
}

// MARK: - SecurityCardFullPriceViewDelegate

extension BuyDetailsViewController: SecurityCardFullPriceViewDelegate {
    func priceViewDidTapPrice(_ priceView: SecurityCardFullPriceView) {
        guard let viewModel = presenter.togglePrice() else { return }
        priceView.updatePrice(viewModel: viewModel)
    }
}
