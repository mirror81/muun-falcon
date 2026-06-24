//
//  SecurityCardFullSpecsPresenter.swift
//  falcon
//
//  Created by Federico Jordán on 20/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

protocol SecurityCardFullSpecsPresenterDelegate: BasePresenterDelegate {
    func update(viewModel: SecurityCardFullSpecsViewModel)
}

final class SecurityCardFullSpecsPresenter
    <Delegate: SecurityCardFullSpecsPresenterDelegate>:
    BasePresenter<Delegate> {

    private let provider: SecurityCardProvider
    private let card: SecurityCard

    init(delegate: Delegate, provider: SecurityCardProvider, card: SecurityCard) {
        self.provider = provider
        self.card = card
        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()
        let extra = SecurityCardProviderExtraInfo.mock(for: provider)
        let providerColor = UIColor(hex: provider.colorHex)

        delegate.update(viewModel: SecurityCardFullSpecsViewModel(
            title: provider.name,
            providerColor: providerColor,
            imageName: card.imageName,
            heightMm: extra.heightMm,
            widthMm: extra.widthMm,
            sections: extra.specSections(
                providerName: provider.name,
                color: providerColor
            )
        ))
    }
}
