//
//  SecurityCardsSlidesConfiguration.swift
//  falcon
//
//  Copyright © 2024 muun. All rights reserved.
//

import UIKit

struct SecurityCardsSlidesConfiguration {

    static let onboarding = SlidesViewConfiguration(
        title: L10n.SecurityCardsOnboarding.title,
        finish: L10n.SecurityCardsOnboarding.finish,
        slides: [
            SlidesViewConfiguration.Slide(
                title: L10n.SecurityCardsOnboarding.slide1Title,
                image: Asset.Assets.envelopeWithLock,
                description: L10n.SecurityCardsOnboarding.slide1Description
            ),
            SlidesViewConfiguration.Slide(
                title: L10n.SecurityCardsOnboarding.slide2Title,
                image: Asset.Assets.ekOptionIcloud,
                description: L10n.SecurityCardsOnboarding.slide2Description
            ),
            SlidesViewConfiguration.Slide(
                title: L10n.SecurityCardsOnboarding.slide3Title,
                image: Asset.Assets.shield,
                description: L10n.SecurityCardsOnboarding.slide3Description
            )
        ],
        screenEvent: "security_cards_onboarding",
        abortTapped: { vc in
            vc.navigationController?.popViewController(animated: true)
        },
        finishTapped: { vc in
            vc.navigationController?.pushViewController(
                MarketplaceViewController(),
                animated: true
            )
        }
    )

}
