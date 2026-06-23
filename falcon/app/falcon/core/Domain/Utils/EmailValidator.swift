//
//  EmailValidator.swift
//  falcon
//
//  Created by Federico Jordán on 29/05/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation

enum EmailValidator {

    private static let emailRegex = "[^@ ]+@[^@ ]+[.][^@ ]*[A-Za-z0-9]$"

    static func isValid(_ string: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: string)
    }
}
