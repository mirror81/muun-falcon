//
//  MarketplacePresenter.swift
//  falcon
//
//  Created by Federico Jordán on 15/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

protocol MarketplacePresenterDelegate: BasePresenterDelegate {
    func update(providers: [SecurityCardProvider])
}

final class MarketplacePresenter<Delegate: MarketplacePresenterDelegate>: BasePresenter<Delegate> {

    private let getSecurityCardsMarketplaceAction: GetSecurityCardsMarketplaceAction = resolve()

    func loadData() {
        subscribeTo(getSecurityCardsMarketplaceAction.run(), onSuccess: { [weak self] providers in
            self?.delegate.update(providers: providers)
        })
    }
}
