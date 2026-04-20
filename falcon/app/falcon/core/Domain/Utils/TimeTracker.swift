//
//  TimeTracker.swift
//  falcon
//
//  Copyright © 2025 muun. All rights reserved.
//

import Foundation

/**
 * List of traces added into the app. The format is prefixCaseName = "PREFIX_ string"
 */
enum TraceLabel: String {
    /// E2E go kit generation
    case ekE2eNewKitGeneration = "EK_ E2E new kit generation"

    /// The go rendering when we already have the data
    case ekNewPdfGeneration = "EK_ New Emergency Kit PDF generation"

    /// Fetching the ekit data for the go kit
    case ekNewDataFetching = "EK_ New Emergency Kit data fetching"

    /// The css/html rendering when we already have the data
    case ekLegacyPdfGeneration = "EK_ LibwalletBridge.generateEmergencyKit"

    /// E2E CSS/HTML kit generation
    case ekE2eLegacyKitGeneration = "EK_ E2E legacy kit generation"
}

enum EmergencyKitChildTrace: String {
    case userKey = "user_key"
    case userFingerprint = "user_fp"
    case muunKey = "muun_key"
    case muunFingerprint = "muun_fp"
    case rcChecksum = "rc_checksum"
}

/// Factory for timing traces. Inject this and call start to begin measuring.
final class TimeTracker {

    /// Start a new trace for label. Call Trace.finish to report.
    func start(_ label: TraceLabel) -> Trace {
        return Trace(label: label.rawValue)
    }
}
