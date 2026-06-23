//
//  GetSecurityCardsMarketplaceAction.swift
//  falcon
//
//  Created by Federico Jordán on 20/02/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import RxSwift

struct SecurityCardProvider {
    let name: String
    let colorHex: String
    let siteUrl: URL?
    let price: Double
    let shippingCost: Double
    let currencyCode: String
    let cards: [SecurityCard]
}

struct SecurityCard {
    let imageName: String
    let stock: Int32
}

final class GetSecurityCardsMarketplaceAction: Resolver {

    private let walletService: WalletService = resolve()

    func run() -> Single<[SecurityCardProvider]> {
        return walletService.getSecurityCardsMarketplace()
    }
}
