//
//  SecurityCardNfcCopyProvider.swift
//  falcon
//
//  Created by Daniel Mankowski on 26/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

enum SecurityCardNfcFlow {
    case pairing
    case challenge
}

struct SecurityCardTextProvider: NfcTextProvider {
    var flow: SecurityCardNfcFlow

    var startMessage: String {
        switch flow {
        // Use the same text for pair and challenge, change later with final implementation
        case .pairing, .challenge:
            // Localize this text whith final version
            return "Hold your Security Card near the top of the iPhone (by the camera)."
        }
    }

    var multipleTagsFound: String {
        // Localize this text with final version
        "Multiple NFC tags detected. Remove other cards and try again."
    }

    var notDetected: String {
        // Localize this text with final version
        "Card not detected. Move it slightly and try again."
    }
}
