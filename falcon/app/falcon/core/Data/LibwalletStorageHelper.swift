//
//  LibwalletStorageHelper.swift
//  Created by Juan Pablo Civile on 22/09/2020.
//

import Foundation

public enum LibwalletStorageHelper: Resolver {

    private static let walletService: WalletService = resolve()

    public static func wipe(preservePin: Bool = false) throws {
        // pinLength is stored in libwallet's KV storage via WalletService. The
        // reset below blows it away, so capture it first when the caller wants to
        // keep the user's PIN configuration intact (mirrors the preservePin flag
        // on secureStorage.wipeAll). Without this, preservePin keeps the PIN
        // value but loses its length, leaving unlock to fall back to a 4-digit
        // keypad even when the user set a 6-digit PIN.
        let preservedPinLength: Int32? = preservePin
            ? walletService.getInt32(key: Persistence.pinLength.rawValue)
            : nil

        try walletService.resetData()

        if let preservedPinLength = preservedPinLength {
            walletService.saveInt32(
                key: Persistence.pinLength.rawValue,
                value: preservedPinLength
            )
        }
    }

    public static func ensureExists() {
        do {
            try FileManager.default.createDirectory(
                at: Environment.current.libwalletDataDirectory,
                withIntermediateDirectories: true,
                attributes: [:]
            )
        } catch {
            Logger.fatal(error: error)
        }
    }

    public static func cleanupSocket() {
        do {
            let socketFile = Environment.current.libwalletSocketFile
            if FileManager.default.fileExists(atPath: socketFile.path) {
                try FileManager.default.removeItem(at: socketFile)
            }
        } catch {
            Logger.fatal(error: error)
        }
    }
}
