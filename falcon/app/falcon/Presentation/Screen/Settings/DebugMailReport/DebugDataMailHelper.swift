//
//  DebugDataMailHelper.swift
//  falcon
//
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation
import MessageUI
import UIKit

struct DebugDataMailHelper {

    static let recipient = "mobile@muun.com"

    static func makeViewController(
        report: DebugDataEmailReport,
        delegate: MFMailComposeViewControllerDelegate
    ) -> UIViewController {
        if MFMailComposeViewController.canSendMail() {
            return makeMailComposer(report: report, delegate: delegate)
        } else {
            return makeShareSheet(report: report)
        }
    }

    private static func makeMailComposer(
        report: DebugDataEmailReport,
        delegate: MFMailComposeViewControllerDelegate
    ) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = delegate
        composer.setToRecipients([recipient])
        composer.setSubject(report.subject)
        composer.setMessageBody(report.body, isHTML: false)

        do {
            let data = try Data(contentsOf: report.attachment)
            composer.addAttachmentData(
                data,
                mimeType: "application/zip",
                fileName: report.attachment.lastPathComponent
            )
        } catch {
            Logger.log(.err, "Could not read debug attachment at \(report.attachment): \(error)")
        }

        return composer
    }

    private static func makeShareSheet(
        report: DebugDataEmailReport
    ) -> UIActivityViewController {
        let item = DebugDataActivityItem(body: report.body, subject: report.subject)
        let items: [Any] = [item, report.attachment]
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
}

private final class DebugDataActivityItem: NSObject, UIActivityItemSource {

    private let body: String
    private let subject: String

    init(body: String, subject: String) {
        self.body = body
        self.subject = subject
        super.init()
    }

    func activityViewControllerPlaceholderItem(
        _ activityViewController: UIActivityViewController
    ) -> Any {
        return body
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        return body
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        return subject
    }
}
