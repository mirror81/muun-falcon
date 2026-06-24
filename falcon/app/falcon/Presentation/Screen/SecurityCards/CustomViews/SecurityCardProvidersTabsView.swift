//
//  SecurityCardProvidersTabsView.swift
//  falcon
//
//  Created by Federico Jordán on 16/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

protocol SecurityCardProvidersTabsViewDelegate: AnyObject {
    func didSelectProvider(at index: Int)
}

final class SecurityCardProvidersTabsView: UIView {

    private enum Constants {
        static let preferredCellsOnScreen: CGFloat = 3
        static let cellHorizontalPadding = MuunTheme.Spacing.xs2
        static let cellHeight: CGFloat = 36
    }

    private var securityCardProviders: [SecurityCardProvider] = []
    private var selectedIndex: Int = 0
    weak var delegate: SecurityCardProvidersTabsViewDelegate?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = .zero
        layout.sectionInset = .zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(type: SecurityCardProvidersCollectionViewCell.self)
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(securityCardProviders: [SecurityCardProvider], selectedIndex: Int) {
        self.securityCardProviders = securityCardProviders
        self.selectedIndex = selectedIndex
        collectionView.reloadData()
        scrollToSelectedIndex(animated: false)
    }

    func setSelectedIndex(_ index: Int, animated: Bool) {
        guard !securityCardProviders.isEmpty else { return }
        selectedIndex = index
        collectionView.reloadData()
        scrollToSelectedIndex(animated: animated)
    }

    private func scrollToSelectedIndex(animated: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.collectionView.scrollToItem(
                at: IndexPath(item: selectedIndex, section: 0),
                at: .centeredHorizontally,
                animated: animated
            )
        }
    }
}

// MARK: - UICollectionViewDataSource

extension SecurityCardProvidersTabsView: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        securityCardProviders.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeue(
            type: SecurityCardProvidersCollectionViewCell.self,
            indexPath: indexPath
        )
        let provider = securityCardProviders[indexPath.item]
        cell.configure(
            name: provider.name,
            color: UIColor(hex: provider.colorHex),
            selected: indexPath.item == selectedIndex
        )
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension SecurityCardProvidersTabsView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectProvider(at: indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SecurityCardProvidersTabsView: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let name = securityCardProviders[indexPath.item].name
        let textWidth = (name as NSString)
            .size(withAttributes: [.font: MuunTheme.Font.Body.lg])
            .width
        let dynamicWidth = ceil(textWidth) + 2 * Constants.cellHorizontalPadding
        let evenWidth = frame.width / Constants.preferredCellsOnScreen
        let cellWidth = max(dynamicWidth, evenWidth)
        return CGSize(width: cellWidth, height: Constants.cellHeight)
    }
}
