//
//  Factory+ChallengeKey.swift
//  falconTests
//
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation
@testable import Muun

extension Factory {

    static func challengeKey(
        type: ChallengeType,
        withSalt: Bool,
        version: Int
    ) -> ChallengeKey {
        // 33-byte compressed secp256k1 public key (valid leading byte + arbitrary body)
        let pubKeyHex = "02" + String(repeating: "ab", count: 32)
        let saltHex = "0102030405060708"

        return ChallengeKey(
            type: type,
            publicKey: Data(hex: pubKeyHex),
            salt: withSalt ? Data(hex: saltHex) : nil,
            challengeVersion: version
        )
    }

}
