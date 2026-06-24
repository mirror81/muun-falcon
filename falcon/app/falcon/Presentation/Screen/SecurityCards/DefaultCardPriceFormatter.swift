//
//  DefaultCardPriceFormatter.swift
//  falcon
//
//  Created by Federico Jordán on 02/06/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation

struct FormattedCardPrice {
    let price: String
    let shipping: String
}

protocol CardPriceFormatter: AnyObject {
    func formattedPrice(for provider: SecurityCardProvider, showBTC: Bool) -> FormattedCardPrice?
}

final class DefaultCardPriceFormatter: CardPriceFormatter {

    private let exchangeRateRepository: ExchangeRateWindowRepository

    init(exchangeRateRepository: ExchangeRateWindowRepository) {
        self.exchangeRateRepository = exchangeRateRepository
    }

    func formattedPrice(
        for provider: SecurityCardProvider,
        showBTC: Bool
    ) -> FormattedCardPrice? {
        if showBTC, let btc = btcPrice(for: provider) {
            return btc
        }
        let code = provider.currencyCode
        return FormattedCardPrice(
            price: format(provider.price, currencyCode: code),
            shipping: format(provider.shippingCost, currencyCode: code)
        )
    }

    private func btcPrice(for provider: SecurityCardProvider) -> FormattedCardPrice? {
        guard let window = exchangeRateRepository.getExchangeRateWindow() else {
            return nil
        }
        let rate: Decimal
        do {
            rate = try window.rate(for: provider.currencyCode)
        } catch {
            return nil
        }
        guard rate > 0 else {
            return nil
        }
        let btcPrice = Decimal(provider.price) / rate
        let btcShipping = Decimal(provider.shippingCost) / rate
        return FormattedCardPrice(
            price: MonetaryAmount(amount: btcPrice, currency: "BTC").toAmountPlusCode(),
            shipping: MonetaryAmount(amount: btcShipping, currency: "BTC").toAmountPlusCode()
        )
    }

    private func format(_ amount: Double, currencyCode: String) -> String {
        MonetaryAmount(amount: Decimal(amount), currency: currencyCode).toAmountPlusCode()
    }
}
