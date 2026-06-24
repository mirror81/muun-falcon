//
//  CountrySelectorPresenter.swift
//  falcon
//
//  Created by Federico Jordán on 06/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

protocol CountrySelectorPresenterDelegate: BasePresenterDelegate {
    func update(countries: [Country])
}

final class CountrySelectorPresenter<Delegate: CountrySelectorPresenterDelegate>:
    BasePresenter<Delegate> {

    // TODO: mock data - replace with actual backend call
    private let allCountries: [Country] = Country.all

    func loadData() {
        delegate.update(countries: allCountries)
    }

    func filter(searchText: String) {
        if searchText.isEmpty {
            delegate.update(countries: allCountries)
        } else {
            delegate.update(countries: allCountries.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.code.localizedCaseInsensitiveContains(searchText)
            })
        }
    }
}
