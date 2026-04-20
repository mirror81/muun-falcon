//
//  TimeTrackerEvent.swift
//  falcon
//
//  Copyright © 2026 muun. All rights reserved.
//

struct TimeTrackerEvent: AnalyticsEvent {

    var name: String { "e_time_tracker" }

    var parameters: [String: AnalyticsValue]? {
        var params: [String: AnalyticsValue] = [
            "label": label,
            "elapsed_ms": elapsedMs
        ]
        children.forEach { params["child_\($0.key)"] = $0.value }
        return params
    }

    let label: String
    let elapsedMs: Int
    // Children are stored as flat params (e.g. "child_user_key": 210) instead of a nested JSON
    // string to keep compatibility with Firebase Analytics' flat key-value model, which makes
    // BigQuery queries straightforward without needing JSON_VALUE() parsing.
    // String (not Int) so unfinished children can be reported as "UNFINISHED". Safe since
    // AnalyticsValue.trackingValue converts everything to String for Firebase anyway.
    let children: [String: String]
}
