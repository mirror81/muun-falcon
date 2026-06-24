//
//  SecurityCardsProviderCarouselViewController.swift
//  falcon
//
//  Created by Federico Jordán on 20/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//
import UIKit

protocol SecurityCardsProviderCarouselViewControllerDelegate: AnyObject {
    func carouselDidSelectCard(
        provider: SecurityCardProvider,
        card: SecurityCard,
        fromView: UIView,
        fromPriceFooter: UIView
    )
}

final class SecurityCardsProviderCarouselViewController: UIViewController {

    private enum Constants {
        static let cardHorizontalInset: CGFloat = 22
        static let cardAspectRatio: CGFloat = 0.63
        static let cardFooterHeight: CGFloat = 72
    }

    private let provider: SecurityCardProvider
    private let footerView = SecurityCardPriceFooterView()
    private weak var priceFormatter: CardPriceFormatter?
    private var isShowingBTC = false

    private lazy var layout: CenterScalingFlowLayout = {
        let l = CenterScalingFlowLayout()
        l.scrollDirection = .vertical
        l.minimumLineSpacing = MuunTheme.Spacing.xl3
        l.sectionInset = UIEdgeInsets(
            top: MuunTheme.Spacing.xl3, left: 0, bottom: MuunTheme.Spacing.xl3, right: 0
        )
        return l
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.decelerationRate = .fast
        cv.dataSource = self
        cv.delegate = self
        cv.register(type: SecurityCardCell.self)
        return cv
    }()

    weak var delegate: SecurityCardsProviderCarouselViewControllerDelegate?

    init(
        provider: SecurityCardProvider,
        priceFormatter: CardPriceFormatter
    ) {
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
        self.priceFormatter = priceFormatter
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFooter()
        setupCollectionView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = itemSize(for: view.bounds.width)
        layout.itemSize = size

        let availableHeight = collectionView.bounds.height
        let verticalInset = max(0, (availableHeight - size.height) / 2)
        layout.sectionInset = UIEdgeInsets(
            top: verticalInset, left: 0, bottom: verticalInset, right: 0
        )
    }

    private func itemSize(for viewWidth: CGFloat) -> CGSize {
        let width = viewWidth - Constants.cardHorizontalInset
        let height = (width * Constants.cardAspectRatio) + Constants.cardFooterHeight
        return CGSize(width: width, height: height)
    }

    private func centeredIndex() -> Int {
        let center = CGPoint(
            x: collectionView.bounds.midX,
            y: collectionView.bounds.midY + collectionView.contentOffset.y
        )

        if let indexPath = collectionView.indexPathForItem(at: center) {
            return indexPath.item
        }

        let centerY = center.y
        return collectionView.indexPathsForVisibleItems
            .min(by: { a, b in
                let aY = collectionView.layoutAttributesForItem(at: a)?.center
                    .y ?? .greatestFiniteMagnitude
                let bY = collectionView.layoutAttributesForItem(at: b)?.center
                    .y ?? .greatestFiniteMagnitude
                return abs(aY - centerY) < abs(bY - centerY)
            })?
            .item ?? 0
    }

    private func scrollToItem(_ index: Int, animated: Bool) {
        collectionView.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .centeredVertically,
            animated: animated
        )
    }

    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: footerView.topAnchor)
        ])
    }

    private func setupFooter() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.delegate = self
        view.addSubview(footerView)

        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let initialPrice = priceFormatter?.formattedPrice(for: provider, showBTC: false)
            ?? FormattedCardPrice(price: "", shipping: "")
        footerView.configure(colorHex: provider.colorHex, price: initialPrice)
    }
}

// MARK: - SecurityCardPriceFooterViewDelegate

extension SecurityCardsProviderCarouselViewController: SecurityCardPriceFooterViewDelegate {
    func footerViewDidTapPrice(_ footerView: SecurityCardPriceFooterView) {
        let newValue = !isShowingBTC
        guard let price = priceFormatter?.formattedPrice(for: provider, showBTC: newValue)
            else { return }
        isShowingBTC = newValue
        footerView.updatePrice(price)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension SecurityCardsProviderCarouselViewController: UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        provider.cards.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeue(type: SecurityCardCell.self, indexPath: indexPath)
        cell.configure(imageName: provider.cards[indexPath.item].imageName)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !(collectionView.isDragging || collectionView.isDecelerating) else { return }

        let card = provider.cards[indexPath.item]
        guard card.stock > 0 else { return }

        let current = centeredIndex()
        guard indexPath.item == current else {
            scrollToItem(indexPath.item, animated: true)
            return
        }

        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        delegate?.carouselDidSelectCard(
            provider: provider,
            card: card,
            fromView: cell,
            fromPriceFooter: footerView
        )
    }
}
