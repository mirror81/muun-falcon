//
//  MarketplacePresenter.swift
//  falcon
//
//  Created by Federico Jordán on 15/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation

protocol MarketplacePresenterDelegate: BasePresenterDelegate {
    func update(providers: [SecurityCardProvider])
}

final class MarketplacePresenter<Delegate: MarketplacePresenterDelegate>: BasePresenter<Delegate> {

    private let getSecurityCardsMarketplaceAction: GetSecurityCardsMarketplaceAction = resolve()
    private let cardPriceFormatter: CardPriceFormatter = resolve()

    func loadData() {
        subscribeTo(getSecurityCardsMarketplaceAction.run(), onSuccess: { [weak self] providers in
            self?.delegate.update(providers: providers)
        })
    }

}

// MARK: - CardPriceFormatter

extension MarketplacePresenter: CardPriceFormatter {

    func formattedPrice(for provider: SecurityCardProvider, showBTC: Bool) -> FormattedCardPrice? {
        cardPriceFormatter.formattedPrice(for: provider, showBTC: showBTC)
    }
}
