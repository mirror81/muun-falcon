//
//  SecurityCardPriceFooterView.swift
//  falcon
//
//  Created by Federico Jordán on 16/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class SecurityCardPriceFooterView: UIView {

    private let topBorder = UIView()
    private let priceLabel = UILabel()
    private let detailLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Asset.Colors.background.color

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
            topBorder.heightAnchor.constraint(equalToConstant: 2)
        ])
    }

    private func setupPriceLabel() {
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = Constant.Fonts.system(size: .h1, weight: .semibold)
        priceLabel.textAlignment = .center
        priceLabel.numberOfLines = 2

        addSubview(priceLabel)

        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: topAnchor, constant: .verticalRowMargin),
            priceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .headerSpacing),
            priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.headerSpacing)
        ])
    }

    private func setupDetailLabel() {
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = Constant.Fonts.system(size: .opDesc, weight: .regular)
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 2
        detailLabel.textColor = Asset.Colors.muunGrayDark.color

        addSubview(detailLabel)

        NSLayoutConstraint.activate([
            detailLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: .closeSpacing),
            detailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .headerSpacing),
            detailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.headerSpacing),
            detailLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.bigSpacing)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(provider: SecurityCardProvider) {
        topBorder.backgroundColor = UIColor(hex: provider.colorHex)
        priceLabel.text = formatPrice(provider.price, currencyCode: provider.currencyCode)
        let shippingPrice = formatPrice(provider.shippingCost, currencyCode: provider.currencyCode)
        detailLabel.text = L10n.SecurityCardPriceFooterView.shippingAndTaxes(shippingPrice)
    }

    private func formatPrice(_ amount: Double, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
        return "\(formatted) \(currencyCode)"
    }
}
