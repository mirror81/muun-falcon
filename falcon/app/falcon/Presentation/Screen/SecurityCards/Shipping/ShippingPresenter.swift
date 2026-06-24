//
//  ShippingPresenter.swift
//  falcon
//
//  Created by Federico Jordán on 20/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

struct ShippingViewModel {
    let providerName: String
    let providerColor: UIColor
    let providerUrl: URL?
    let country: String
}

protocol ShippingPresenterDelegate: BasePresenterDelegate {
    func update(viewModel: ShippingViewModel)
    func displayFormErrors(_ errors: [ShippingFormField: String])
}

final class ShippingPresenter<Delegate: ShippingPresenterDelegate>: BasePresenter<Delegate> {

    private let provider: SecurityCardProvider
    private let getSecurityCardCountryAction: GetSecurityCardCountryAction = resolve()

    var providerURL: URL? { provider.siteUrl }

    init(delegate: Delegate, provider: SecurityCardProvider) {
        self.provider = provider
        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()
        subscribeTo(getSecurityCardCountryAction.run(), onSuccess: { [weak self] country in
            guard let self else { return }
            self.delegate.update(viewModel: self.buildViewModel(country: country))
        })
    }

    /// Validates the submitted form. On success the checkout flow continues (next PR);
    /// otherwise per-field errors are pushed back to the view.
    func submit(_ values: ShippingFormValues) {
        let errors = validationErrors(for: values)
        guard errors.isEmpty else {
            delegate.displayFormErrors(errors)
            return
        }
        // TODO: navigate to OrderSummaryViewController (next PR)
    }

    private func validationErrors(for values: ShippingFormValues) -> [ShippingFormField: String] {
        var errors: [ShippingFormField: String] = [:]

        let requiredFields: [(ShippingFormField, String, String)] = [
            (.fullName, values.fullName, L10n.ShippingFormView.fullNameRequired),
            (.email, values.email, L10n.ShippingFormView.emailRequired),
            (
                .shippingAddress,
                values.shippingAddress,
                L10n.ShippingFormView.shippingAddressRequired
            ),
            (.city, values.city, L10n.ShippingFormView.cityRequired),
            (.state, values.state, L10n.ShippingFormView.stateRequired),
            (.zipCode, values.zipCode, L10n.ShippingFormView.zipCodeRequired)
        ]

        for (key, value, message) in requiredFields where value.isEmpty {
            errors[key] = message
        }

        if !values.email.isEmpty && !EmailValidator.isValid(values.email) {
            errors[.email] = L10n.ShippingFormView.emailInvalid
        }

        return errors
    }

    private func buildViewModel(country: Country) -> ShippingViewModel {
        ShippingViewModel(
            providerName: provider.name,
            providerColor: UIColor(hex: provider.colorHex),
            providerUrl: provider.siteUrl,
            country: "\(country.flag) \(country.name)"
        )
    }
}
