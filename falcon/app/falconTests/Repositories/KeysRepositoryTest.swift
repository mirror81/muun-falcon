//
//  KeysRepositoryTest.swift
//  falconTests
//
//  Copyright © 2026 muun. All rights reserved.
//

import XCTest
@testable import Muun

class KeysRepositoryTest: MuunTestCase {
    lazy var keysRepository: KeysRepository = resolve()
    lazy var secureStorage: SecureStorage = resolve()
    lazy var userRepository: UserRepository = resolve()
    lazy var keychainRepository: KeychainRepository = resolve()

    // MARK: - Base private key (user key)

    func test_basePrivateKey_storeAndRetrieve() throws {
        let key = WalletPrivateKey.createRandom()

        try keysRepository.store(key: key)

        let retrieved = try keysRepository.getBasePrivateKey()
        XCTAssertEqual(retrieved.toBase58(), key.toBase58())
    }

    // MARK: - Encrypted muun private key

    func test_muunPrivateKey_storeAndRetrieve() throws {
        let keyData = "encrypted-muun-private-key-data"

        try keysRepository.store(muunPrivateKey: keyData)

        XCTAssertEqual(try keysRepository.getMuunPrivateKey(), keyData)
    }

    // MARK: - Challenge keys

    func test_challengeKey_PASSWORD_storeAndRetrieve() throws {
        let original = Factory.challengeKey(type: .PASSWORD, withSalt: true, version: 1)

        try keysRepository.storeVerified(challengeKey: original)

        XCTAssertEqual(try keysRepository.getChallengeKey(with: .PASSWORD), original)
    }

    func test_challengeKey_RECOVERY_CODE_storeAndRetrieve() throws {
        let original = Factory.challengeKey(type: .RECOVERY_CODE, withSalt: false, version: 2)

        try keysRepository.storeVerified(challengeKey: original)

        XCTAssertEqual(try keysRepository.getChallengeKey(with: .RECOVERY_CODE), original)
    }

    func test_storeVerified_PASSWORD_marksUserChallengeKeyFlag() throws {
        setupBasicData()
        let challengeKey = Factory.challengeKey(type: .PASSWORD, withSalt: true, version: 1)

        try keysRepository.storeVerified(challengeKey: challengeKey)

        XCTAssertTrue(userRepository.getUser()!.hasPasswordChallengeKey)
    }

    func test_storeVerified_RECOVERY_CODE_marksUserChallengeKeyFlag() throws {
        setupBasicData()
        let challengeKey = Factory.challengeKey(type: .RECOVERY_CODE, withSalt: false, version: 2)

        try keysRepository.storeVerified(challengeKey: challengeKey)

        XCTAssertTrue(userRepository.getUser()!.hasRecoveryCodeChallengeKey)
    }

    func test_challengeKey_PASSWORD_storedAsSeparateEntries() throws {
        let challengeKey = Factory.challengeKey(type: .PASSWORD, withSalt: true, version: 1)

        try keysRepository.storeVerified(challengeKey: challengeKey)

        XCTAssertTrue(try secureStorage.has(.passwordPublicKey))
        XCTAssertTrue(try secureStorage.has(.passwordSalt))
        XCTAssertTrue(try secureStorage.has(.passwordVersionKey))
    }

    func test_challengeKey_RECOVERY_CODE_storedAsSeparateEntries() throws {
        let challengeKey = Factory.challengeKey(type: .RECOVERY_CODE, withSalt: false, version: 2)

        try keysRepository.storeVerified(challengeKey: challengeKey)

        XCTAssertTrue(try secureStorage.has(.recoveryCodePublicKey))
        XCTAssertFalse(try secureStorage.has(.recoveryCodeSalt))
        XCTAssertTrue(try secureStorage.has(.recoveryCodeVersionKey))
    }

    func test_challengeKey_USER_KEY_storedAsSeparateEntries() throws {
        let challengeKey = Factory.challengeKey(type: .USER_KEY, withSalt: false, version: 1)

        try keysRepository.storeVerified(challengeKey: challengeKey)

        XCTAssertTrue(try secureStorage.has(.userKeyPublicKey))
        XCTAssertTrue(try secureStorage.has(.userVersionKey))
    }

    // MARK: - Wipe

    func test_wipe_clearsKeysRepositoryKeys() throws {
        let key = WalletPrivateKey.createRandom()
        try keysRepository.store(key: key)
        try keysRepository.store(muunPrivateKey: "encrypted-muun-data")

        secureStorage.wipeAll()

        XCTAssertNil(try? keysRepository.getBasePrivateKey())
        XCTAssertNil(try? keysRepository.getMuunPrivateKey())
    }

    func test_wipe_clearsChallengeKeyEntries() throws {
        let password = Factory.challengeKey(type: .PASSWORD, withSalt: true, version: 1)
        let recoveryCode = Factory.challengeKey(type: .RECOVERY_CODE, withSalt: false, version: 2)
        try keysRepository.storeVerified(challengeKey: password)
        try keysRepository.storeVerified(challengeKey: recoveryCode)

        secureStorage.wipeAll()

        XCTAssertFalse(try secureStorage.has(.passwordPublicKey))
        XCTAssertFalse(try secureStorage.has(.passwordSalt))
        XCTAssertFalse(try secureStorage.has(.passwordVersionKey))
        XCTAssertFalse(try secureStorage.has(.recoveryCodePublicKey))
        XCTAssertFalse(try secureStorage.has(.recoveryCodeVersionKey))
    }

    func test_wipe_preservesKeychainPersistentKeys() throws {
        let deviceCheckTokenKey = KeychainRepository.storedKeys.deviceCheckToken.rawValue
        let deviceCheckTokenValue = "device-check-token-value"
        try keychainRepository.store(deviceCheckTokenValue, at: deviceCheckTokenKey)
        try keysRepository.store(key: WalletPrivateKey.createRandom())

        secureStorage.wipeAll()

        XCTAssertEqual(
            try keychainRepository.get(deviceCheckTokenKey),
            deviceCheckTokenValue
        )
    }
}
