//
//  BuyDetailsPresenter.swift
//  falcon
//
//  Created by Federico Jordán on 13/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

protocol BuyDetailsPresenterDelegate: BasePresenterDelegate {
    func update(viewModel: BuyDetailsViewModel)
}

final class BuyDetailsPresenter<Delegate: BuyDetailsPresenterDelegate>: BasePresenter<Delegate> {
    struct State {
        let provider: SecurityCardProvider
        let card: SecurityCard
    }

    private let cardPriceFormatter: CardPriceFormatter = resolve()
    private let state: State
    private var isShowingBTC = false

    init(delegate: Delegate, state: State) {
        self.state = state
        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        let provider = state.provider
        let extra = SecurityCardProviderExtraInfo.mock(for: provider)

        delegate.update(viewModel: BuyDetailsViewModel(
            title: provider.name,
            description: L10n.BuyDetailsViewController.trustedBecause(extra.description),
            providerColor: UIColor(hex: provider.colorHex),
            imageName: state.card.imageName,
            material: extra.material,
            shipsFrom: extra.shipsFrom,
            deliveryDays: extra.deliveryDays,
            priceViewModel: fiatViewModel(),
            ctaTitle: L10n.BuyDetailsViewController.goTo(provider.name.uppercased())
        ))
    }

    func togglePrice() -> SecurityCardFullPriceView.ViewModel? {
        let next = !isShowingBTC
        guard let price = cardPriceFormatter.formattedPrice(
            for: state.provider,
            showBTC: next
        ) else {
            return nil
        }
        isShowingBTC = next
        return SecurityCardFullPriceView.ViewModel(
            price: price.price,
            shippingCost: price.shipping
        )
    }

    private func fiatViewModel() -> SecurityCardFullPriceView.ViewModel {
        let fiat = cardPriceFormatter.formattedPrice(for: state.provider, showBTC: false)!
        return SecurityCardFullPriceView.ViewModel(
            price: fiat.price,
            shippingCost: fiat.shipping
        )
    }
}
