//
//  BuyDetailsRowView.swift
//  falcon
//
//  Created by Federico Jordán on 13/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class BuyDetailsRowView: UIView {
    private enum Constants {
        static let rowHeight = MuunTheme.Legacy.s44
    }

    init(leadingView: UIView, valueLabel: UILabel) {
        super.init(frame: .zero)

        leadingView.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(leadingView)
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.rowHeight),
            leadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            leadingView.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            leadingView.trailingAnchor.constraint(
                lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -MuunTheme.Spacing.xs
            )
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
