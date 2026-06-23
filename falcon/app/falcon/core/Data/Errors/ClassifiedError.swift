//
//  ClassifiedError.swift
//  falcon
//
//  Copyright 2026 muun. All rights reserved.
//

import Foundation

/// Classification of errors for analytics and reporting purposes.
/// - `expected`: Errors anticipated from user input or external factors
///              (e.g., insufficient funds, invalid address).
///              These don't require investigation in general.
/// - `unexpected`: Every error that is NOT classified as expected (e.g cause by a user action
///                and/or incorrect input).
///                These MAY be caused by bugs or conditions not under user control (e.g network
///                connectivity, mempool state, etc...).
///
/// All errors are sent to both Analytics and Crashlytics. The classification is included
/// as a parameter (`error_classification`) to allow filtering on the analytics backend.
public enum ErrorClassification: String {
    case expected
    case unexpected
}

/// Protocol for error types that provide their own classification.
///
/// Error types that conform to this protocol will have their classification
/// automatically used by MuunError. For errors that don't conform,
/// MuunError defaults to `.unexpected` (safe default).
///
/// When implementing, use a switch statement covering all cases to ensure
/// the compiler forces you to classify each error case explicitly.
public protocol ClassifiedError {
    var classification: ErrorClassification { get }
}
