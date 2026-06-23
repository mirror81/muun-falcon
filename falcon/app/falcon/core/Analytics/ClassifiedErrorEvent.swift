//
//  ClassifiedErrorEvent.swift
//  falcon
//
//  Created by Daniel Mankowski on 20/04/2026.
//  Copyright © 2026 muun. All rights reserved.
//

/// An analytics event that carries error classification derived from the captured error.
/// The `error_classification` parameter is automatically added to allow
/// filtering on the analytics backend.
protocol ClassifiedErrorEvent: AnalyticsEvent {
    var error: Error { get }
}

extension ClassifiedErrorEvent {
    var errorClassification: ErrorClassification {
        if let muunError = error as? MuunError {
            return muunError.classification
        } else if let classified = error as? ClassifiedError {
            return classified.classification
        } else {
            return .unexpected
        }
    }
}
