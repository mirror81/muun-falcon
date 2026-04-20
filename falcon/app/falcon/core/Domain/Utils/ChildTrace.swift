//
//  ChildTrace.swift
//  falcon
//
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation

final class ChildTrace {

    private let label: String
    private let startTime: UInt64 = clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW)
    private var elapsedMs: Int?

    init(label: String) {
        self.label = label
    }

    func finish() {
        guard elapsedMs == nil else {
            let log = "[TIMING] \(label) finished more than once"
            Logger.log(error: NSError(domain: log, code: 1))
            assertionFailure(log)
            return
        }
        elapsedMs = Int((clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW) - startTime) / 1_000_000)
    }

    func result() -> (String, String) {
        (label, elapsedMs.map { String($0) } ?? "UNFINISHED")
    }
}
