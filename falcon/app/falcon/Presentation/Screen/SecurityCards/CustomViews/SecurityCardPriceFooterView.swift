//
//  SecurityCardPriceFooterView.swift
//  falcon
//
//  Created by Federico Jordán on 16/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

protocol SecurityCardPriceFooterViewDelegate: AnyObject {
    func footerViewDidTapPrice(_ footerView: SecurityCardPriceFooterView)
}

final class SecurityCardPriceFooterView: UIView {

    private enum Constants {
        static let topBorderHeight: CGFloat = 2
    }

    weak var delegate: SecurityCardPriceFooterViewDelegate?

    private let topBorder = UIView()
    private let priceLabel = UILabel()
    private let detailLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = MuunTheme.Color.Surface.background

        setupTopBorder()
        setupPriceLabel()
        setupDetailLabel()
    }

    private func setupTopBorder() {
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topBorder)
        NSLayoutConstraint.activate([
            topBorder.topAnchor.constraint(equalTo: topAnchor),
            topBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
            topBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
            topBorder.heightAnchor.constraint(equalToConstant: Constants.topBorderHeight)
        ])
    }

    private func setupPriceLabel() {
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = MuunTheme.Font.Heading.h1
        priceLabel.textAlignment = .center
        priceLabel.numberOfLines = 2
        priceLabel.isUserInteractionEnabled = true
        priceLabel.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(didTapPrice)
            )
        )

        addSubview(priceLabel)

        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(
                equalTo: topAnchor,
                constant: MuunTheme.Spacing.md
            ),
            priceLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            priceLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            )
        ])
    }

    private func setupDetailLabel() {
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = MuunTheme.Font.Body.lg
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 2
        detailLabel.textColor = MuunTheme.Color.Text.bodySecondary

        addSubview(detailLabel)

        NSLayoutConstraint.activate([
            detailLabel.topAnchor.constraint(
                equalTo: priceLabel.bottomAnchor,
                constant: MuunTheme.Spacing.xs3
            ),
            detailLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            detailLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            ),
            detailLabel.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor
            )
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(colorHex: String, price: FormattedCardPrice) {
        topBorder.backgroundColor = UIColor(hex: colorHex)
        priceLabel.text = price.price
        detailLabel.text = "+ \(price.shipping) \(L10n.SecurityCardPriceFooterView.shippingAndTaxes)"
    }

    func updatePrice(_ price: FormattedCardPrice) {
        UIView.animate(withDuration: 0.1, animations: {
            self.priceLabel.alpha = 0.6
            self.detailLabel.alpha = 0.6
        }, completion: { _ in
            self.priceLabel.text = price.price
            self.detailLabel.text = price.shipping
            UIView.animate(withDuration: 0.15) {
                self.priceLabel.alpha = 1
                self.detailLabel.alpha = 1
            }
        })
    }

    @objc private func didTapPrice() {
        delegate?.footerViewDidTapPrice(self)
    }
}
