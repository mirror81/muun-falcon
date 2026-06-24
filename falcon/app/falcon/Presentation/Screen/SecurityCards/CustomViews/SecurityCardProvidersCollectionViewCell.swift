//
//  SecurityCardProvidersCollectionViewCell.swift
//  falcon
//
//  Created by Federico Jordán on 16/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class SecurityCardProvidersCollectionViewCell: UICollectionViewCell {
    private enum Constants {
        static let bottomLineHeight: CGFloat = 2
    }

    private let label = UILabel()
    private let bottomLineView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLabel()
        setupBottomLineView()
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLabel() {
        label.font = MuunTheme.Font.Body.lg
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
    }

    private func setupBottomLineView() {
        bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomLineView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: MuunTheme.Spacing.xs2
            ),
            label.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -MuunTheme.Spacing.xs2
            ),
            label.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: MuunTheme.Spacing.xs
            ),
            label.bottomAnchor.constraint(
                equalTo: bottomLineView.topAnchor,
                constant: -MuunTheme.Spacing.xs
            ),
            bottomLineView.heightAnchor.constraint(equalToConstant: Constants.bottomLineHeight),
            bottomLineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func configure(name: String, color: UIColor, selected: Bool) {
        label.text = name
        if selected {
            label.textColor = color
            bottomLineView.backgroundColor = color
        } else {
            label.textColor = MuunTheme.Color.Text.bodyPrimary
            bottomLineView.backgroundColor = .clear
        }
    }
}
