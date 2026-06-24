//
//  SecurityCardSpecsListView.swift
//  falcon
//
//  Created by Federico Jordán on 20/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

protocol SecurityCardSpecsListViewDelegate: AnyObject {
    func didTapInfo(forItem item: SecurityCardSpecsListView.SpecItemViewModel)
}

final class SecurityCardSpecsListView: UIView {

    struct SpecItemViewModel {
        let symbol: String
        let label: String
        let value: String
        let additionalHTMLData: String?
    }

    struct ViewModel {
        let title: String
        let rows: [SpecItemViewModel]
        let providerColor: UIColor
    }

    private enum Constants {
        static let cornerRadius: CGFloat = 8
        static let borderWidth: CGFloat = 0.5
        static let backgroundAlpha: CGFloat = 0.05
        static let rowHeight = MuunTheme.Legacy.s44
        static let iconSize = MuunTheme.Legacy.s18
        static let titleSpacing = MuunTheme.Spacing.xs
    }

    private weak var delegate: SecurityCardSpecsListViewDelegate?

    private let titleLabel = UILabel()
    private let rowsStack = UIStackView()

    init(delegate: SecurityCardSpecsListViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)

        titleLabel.font = Constant.Fonts.system(size: .desc, weight: .semibold)
        titleLabel.textColor = MuunTheme.Color.Text.bodyPrimary

        rowsStack.axis = .vertical
        rowsStack.spacing = 0
        rowsStack.clipsToBounds = true
        rowsStack.layer.cornerRadius = Constants.cornerRadius
        rowsStack.layer.borderWidth = Constants.borderWidth

        let outerStack = UIStackView(arrangedSubviews: [titleLabel, rowsStack])
        outerStack.axis = .vertical
        outerStack.spacing = Constants.titleSpacing
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outerStack)
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: topAnchor),
            outerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            outerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            outerStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        rowsStack.layer.borderColor = MuunTheme.Color.Border.primary.cgColor
    }

    func configure(viewModel: ViewModel) {
        titleLabel.text = viewModel.title
        rowsStack.backgroundColor = viewModel.providerColor
            .withAlphaComponent(Constants.backgroundAlpha)

        rowsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in viewModel.rows {
            rowsStack.addArrangedSubview(makeRow(item: item))
        }
    }

    private func makeRow(item: SpecItemViewModel) -> UIView {
        let icon = UIImageView(image: UIImage(systemName: item.symbol))
        icon.tintColor = MuunTheme.Color.Text.bodySecondary
        icon.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            icon.heightAnchor.constraint(equalToConstant: Constants.iconSize)
        ])

        let labelView = UILabel()
        labelView.text = item.label
        labelView.font = Constant.Fonts.system(size: .opDesc)
        labelView.textColor = MuunTheme.Color.Text.bodySecondary
        labelView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let valueLabel = UILabel()
        valueLabel.text = item.value
        valueLabel.font = Constant.Fonts.system(size: .opDesc)
        valueLabel.textAlignment = .right
        valueLabel.textColor = MuunTheme.Color.Text.bodyPrimary
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        var subviews: [UIView] = [icon, labelView, valueLabel]
        if item.additionalHTMLData != nil {
            let infoIcon = UIImageView(image: UIImage(systemName: "info.circle"))
            infoIcon.tintColor = MuunTheme.Color.Text.bodySecondary
            infoIcon.contentMode = .scaleAspectFit
            NSLayoutConstraint.activate([
                infoIcon.widthAnchor.constraint(equalToConstant: MuunTheme.Spacing.md),
                infoIcon.heightAnchor.constraint(equalToConstant: MuunTheme.Spacing.md)
            ])
            subviews.append(infoIcon)
        }

        let container = SpecRowContainer(item: item, arrangedSubviews: subviews)
        container.heightAnchor.constraint(equalToConstant: Constants.rowHeight)

            .isActive = true
        if item.additionalHTMLData != nil {
            container.isUserInteractionEnabled = true
            container.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(didTapRow(_:)))
            )
        }
        return container
    }

    @objc private func didTapRow(_ gesture: UITapGestureRecognizer) {
        guard let container = gesture.view as? SpecRowContainer else { return }
        delegate?.didTapInfo(forItem: container.item)
    }
}

private final class SpecRowContainer: UIStackView {
    let item: SecurityCardSpecsListView.SpecItemViewModel

    init(
        item: SecurityCardSpecsListView.SpecItemViewModel,
        arrangedSubviews: [UIView]
    ) {
        self.item = item
        super.init(frame: .zero)
        for view in arrangedSubviews {
            addArrangedSubview(view)
        }
        axis = .horizontal
        alignment = .center
        spacing = MuunTheme.Spacing.xs
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = .init(
            top: 0, leading: MuunTheme.Spacing.xs, bottom: 0, trailing: MuunTheme.Spacing.xs
        )
    }

    @available(*, unavailable)
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
