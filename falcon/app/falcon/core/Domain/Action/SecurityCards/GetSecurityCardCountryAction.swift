//
//  GetSecurityCardCountryAction.swift
//  falcon
//
//  Created by Federico Jordán on 29/05/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import RxSwift

final class GetSecurityCardCountryAction: Resolver {

    func run() -> Single<Country> {
        // TODO: replace with the country selected during security cards onboarding.
        return .just(Country(code: "AR", name: "Argentina", flag: "🇦🇷"))
    }
}
