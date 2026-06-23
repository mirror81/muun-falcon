//
//  SecurityCardFullPriceView.swift
//  falcon
//
//  Created by Federico Jordán on 13/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

protocol SecurityCardFullPriceViewDelegate: AnyObject {
    func priceViewDidTapPrice(_ priceView: SecurityCardFullPriceView)
}

final class SecurityCardFullPriceView: UIView {

    struct ViewModel {
        let price: String
        let shippingCost: String
    }

    private weak var delegate: SecurityCardFullPriceViewDelegate?

    private let priceLabel = UILabel()
    private let shippingLabel = UILabel()

    init(delegate: SecurityCardFullPriceViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: ViewModel) {
        priceLabel.text = viewModel.price
        shippingLabel.text = L10n.BuyDetailsViewController.additionalCosts(viewModel.shippingCost)
    }

    func updatePrice(viewModel: ViewModel) {
        UIView.animate(withDuration: 0.1, animations: {
            self.priceLabel.alpha = 0.6
            self.shippingLabel.alpha = 0.6
        }, completion: { _ in
            self.configure(viewModel: viewModel)
            UIView.animate(withDuration: 0.15) {
                self.priceLabel.alpha = 1
                self.shippingLabel.alpha = 1
            }
        })
    }

    private func setupView() {
        priceLabel.font = MuunTheme.Font.Heading.h1
        priceLabel.numberOfLines = 1
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.isUserInteractionEnabled = true
        priceLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapPrice))
        )
        addSubview(priceLabel)

        shippingLabel.font = MuunTheme.Font.Body.lg
        shippingLabel.textColor = MuunTheme.Color.Text.bodySecondary
        shippingLabel.numberOfLines = 1
        shippingLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(shippingLabel)

        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: topAnchor),
            priceLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            shippingLabel.topAnchor.constraint(
                equalTo: priceLabel.bottomAnchor,
                constant: MuunTheme.Spacing.xs2
            ),
            shippingLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            shippingLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            shippingLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func didTapPrice() {
        delegate?.priceViewDidTapPrice(self)
    }
}
