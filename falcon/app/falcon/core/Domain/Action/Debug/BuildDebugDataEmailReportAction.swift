//
//  BuildDebugDataEmailReportAction.swift
//  falcon
//
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

struct DebugDataEmailReport {
    let subject: String
    let body: String
    let attachment: URL
}

final class BuildDebugDataEmailReportAction: AsyncAction<DebugDataEmailReport> {

    private static let zipFileName = "libwallet-data.zip"

    private let walletService: WalletService
    private let sessionActions: SessionActions

    private var libwalletZipURL: URL {
        let temporaryDirectoryURL = URL(
            fileURLWithPath: NSTemporaryDirectory(),
            isDirectory: true
        )
        let url = temporaryDirectoryURL.appendingPathComponent(
            Self.zipFileName
        )
        walletService.zipDataDir(outputPath: url.path)
        return url
    }

    init(walletService: WalletService, sessionActions: SessionActions) {
        self.walletService = walletService
        self.sessionActions = sessionActions

        super.init(name: "BuildDebugDataEmailReportAction")
    }

    public func run() {
        let single = Single<DebugDataEmailReport>.create { [weak self] callback in
            guard let self = self else {
                return Disposables.create()
            }

            let zipURL = libwalletZipURL
            let user = self.sessionActions.getUser()
            let report = DebugDataEmailReport(
                subject: self.buildSubject(user: user),
                body: self.buildBody(user: user),
                attachment: zipURL
            )
            callback(.success(report))
            return Disposables.create()
        }
        runSingle(single)
    }

    private func buildSubject(user: User?) -> String {
        let supportId = user?.getSupportId() ?? "anonymous"
        return "Muun debug data (\(supportId))"
    }

    private func buildBody(user: User?) -> String {
        let supportId = user?.getSupportId() ?? "Not logged in"
        return """
            App version: \(Constant.buildVersion)
            SupportId: \(supportId)
            OS Version: \(UIDevice.current.systemVersion)
            DeviceModel: \(UIDevice.current.model)
        """
    }
}
