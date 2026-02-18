//
//  AnalyticsValue.swift
//  falcon
//
//  Created by Daniel Mankowski on 08/02/2026.
//  Copyright © 2026 muun. All rights reserved.
//

/// A strongly-typed analytics value.
/// Everything is converted to a String before being sent to BigQuery.
protocol AnalyticsValue {
    var trackingValue: String { get }
}

/// Each data type used for tracking must implements AnalyticsValue and be converted
/// to a String value

extension String: AnalyticsValue {
    var trackingValue: String {
        self
    }
}

extension Bool: AnalyticsValue {
    var trackingValue: String {
        self ? "true" : "false"
    }
}

extension Int: AnalyticsValue {
    var trackingValue: String {
        String(self)
    }
}

extension Int64: AnalyticsValue {
    var trackingValue: String {
        String(self)
    }
}

extension Double: AnalyticsValue {
    var trackingValue: String {
        String(self)
    }
}
