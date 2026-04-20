//
//  SecurityCardProvidersCollectionViewCell.swift
//  falcon
//
//  Created by Federico Jordán on 16/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class SecurityCardProvidersCollectionViewCell: UICollectionViewCell {
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
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
    }

    private func setupBottomLineView() {
        bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomLineView)
    }

    private func setupConstraints() {
        let horizontalPadding: CGFloat = 12
        let verticalPadding: CGFloat = 8
        let lineHeight: CGFloat = 2
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding),
            label.bottomAnchor.constraint(equalTo: bottomLineView.topAnchor, constant: -verticalPadding),
            bottomLineView.heightAnchor.constraint(equalToConstant: lineHeight),
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
            label.textColor = .label
            bottomLineView.backgroundColor = .clear
        }
    }
}
