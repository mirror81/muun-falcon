//
//  SecurityCardsSlidesConfiguration.swift
//  falcon
//
//  Copyright © 2024 muun. All rights reserved.
//

import UIKit

struct SecurityCardsSlidesConfiguration {

    static let slides: [SlidesViewConfiguration.Slide] = [
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
    ]

}
