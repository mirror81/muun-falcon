//
//  AnalyticsEvent.swift
//  falcon
//
//  Created by Federico Jordán on 05/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

/// Represents a typed analytics event.
/// Each event is responsible for defining:
/// - its event name (`name`)
/// - the parameters it reports, using typed keys
///
/// Example:
///
/// ```
/// struct LoginSucceededEvent: AnalyticsEvent {
///     let title = "login_succeeded"
///     let parameters: [String: AnalyticsValue]? = [
///         "type": "email"
///     ]
/// }
/// ```
protocol AnalyticsEvent {
    var name: String { get }
    var parameters: [String: AnalyticsValue]? { get }
}

extension AnalyticsEvent {
    func buildParamsFor(error: Error) -> [String: AnalyticsValue] {
        return [
            "errorLocalizedMessage": error.localizedDescription
        ]
    }
}
