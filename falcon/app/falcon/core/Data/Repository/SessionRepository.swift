//
//  SessionRepository.swift
//  falcon
//
//  Created by Juan Pablo Civile on 06/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift

class SessionRepository {

    private let preferences: Preferences
    private let secureStorage: SecureStorage
    private let walletService: WalletService

    init(preferences: Preferences, secureStorage: SecureStorage, walletService: WalletService) {
        self.preferences = preferences
        self.secureStorage = secureStorage
        self.walletService = walletService
    }

    func setStatus(_ status: SessionStatus) {
        preferences.set(object: status, forKey: .sessionStatus)
    }

    func watchStatus() -> Observable<SessionStatus?> {
        return preferences.watchObject(key: .sessionStatus)
    }

    func getStatus() -> SessionStatus? {
        return preferences.object(forKey: .sessionStatus)
    }

    func store(pin: String) throws {
        try secureStorage.store(pin, at: .pin)
    }

    func getPin() throws -> String {
        return try self.secureStorage.get(.pin)
    }
    
    func hasPin() throws -> Bool  {
        return try self.secureStorage.has(.pin)
    }

    func store(pinAttemptsLeft: Int) throws {
        let pinAttemptsString = String(describing: pinAttemptsLeft)
        try secureStorage.store(pinAttemptsString, at: .pinAttemptsLeft)
    }

    func getPinAttemptsLeft() throws -> Int {
        let pinAttemptsLeft = try secureStorage.get(.pinAttemptsLeft)
        return Int(pinAttemptsLeft) ?? 0
    }

    func store(pinLength: Int) {
        let int32PinLength = Int32(pinLength)
        walletService.saveInt32(
            key: Persistence.pinLength.rawValue,
            value: int32PinLength
        )
    }

    func getPinLength() -> Int {
        let legacyPinLength: Int32 = Int32(PinLength.legacy)
        let pinLength = walletService.getInt32(
            key: Persistence.pinLength.rawValue,
            defaultValue: legacyPinLength
        )
        return Int(pinLength)
    }

    func storeAuthToken(_ authToken: String) throws {
        try secureStorage.store(authToken, at: .authToken)
    }

    func getAuthToken() throws -> String {
        return try self.secureStorage.get(.authToken)
    }

    func hasAuthToken() throws -> Bool {
        return try self.secureStorage.has(.authToken)
    }

    func deleteAuthToken() {
        secureStorage.delete(.authToken)
    }

    func store(lastNotificationId: Int) {
        preferences.set(value: lastNotificationId, forKey: .lastNotificationId)
    }

    func getLastNotificationId() -> Int {
        return preferences.integer(forKey: .lastNotificationId)
    }

    func setBiometricIdStatus(_ status: Bool) {
        preferences.set(object: status, forKey: .isBiometricIdSet)
    }

    func getBiometricIdStatus() -> Bool? {
        return preferences.object(forKey: .isBiometricIdSet)
    }
}
