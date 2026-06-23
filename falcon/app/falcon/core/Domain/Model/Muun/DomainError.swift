//
//  DomainError.swift
//
//  Created by Lucas Serruya on 13/09/2023.
//

import Foundation

public enum DomainError: Error {
    case sessionExpiredOnNotificationProcessor
    case emergencyKitExportError
    case invalidSwap
}

extension DomainError: ClassifiedError {
    public var classification: ErrorClassification {
        switch self {
        case .sessionExpiredOnNotificationProcessor, .emergencyKitExportError, .invalidSwap:
            return .unexpected
        }
    }
}
