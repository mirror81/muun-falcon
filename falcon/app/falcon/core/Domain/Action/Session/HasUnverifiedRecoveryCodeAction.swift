//
//  HasUnverifiedRecoveryCodeAction.swift
//  falcon
//
//  Created by Daniel Mankowski on 23/02/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation

class HasUnverifiedRecoveryCodeAction {

    private let secureStorage: SecureStorage
    private let preferences: Preferences
    private let userRepository: UserRepository

    init(secureStorage: SecureStorage,
         preferences: Preferences,
         userRepository: UserRepository) {
        self.secureStorage = secureStorage
        self.preferences = preferences
        self.userRepository = userRepository
    }

    /// Checks if there's an unverified Recovery Code available to the user.
    /// This can happen in two scenarios:
    /// - Device A: User generates an RC but doesn't complete the
    ///   verification flow (publicKey in keychain).
    /// - Device B: User logged in with an unverified RC (hasResolvedARcChallenge = true).
    func run() -> Bool {
        // If the user already has a verified RC, return false
        if hasVerifiedRecoveryCode() {
            return false
        }

        // Device B: User logged in with RC (if true, we are on Device B)
        if preferences.bool(forKey: .hasResolvedARcChallenge) {
            return true
        }

        // Device A: RC public key exists in keychain (generated but not verified)
        do {
            return try secureStorage.has(.recoveryCodePublicKey)
        } catch {
            Logger.log(error: error)
            return false
        }
    }

    private func hasVerifiedRecoveryCode() -> Bool {
        return userRepository.getUser()?.hasRecoveryCodeChallengeKey ?? false
    }
}
