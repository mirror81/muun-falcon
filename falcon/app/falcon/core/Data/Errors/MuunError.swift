//
//  MuunError.swift
//  falcon
//
//  Created by Juan Pablo Civile on 22/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

public struct MuunError: Error, LocalizedError {

    let stacktrace: [NSNumber]
    let callsite: String
    let shortCallsite: String
    public let kind: Error
    public let classification: ErrorClassification

    /// Creates a MuunError wrapping the given error.
    ///
    /// Classification is determined by:
    /// 1. If `classification` parameter is provided, use it
    /// 2. If the error conforms to `ClassifiedError`, use its classification
    /// 3. Otherwise, default to `.unexpected` (safe default)
    @inline(never)
    public init(
        _ kind: Error,
        classification: ErrorClassification? = nil,
        filename: StaticString = #file,
        line: UInt = #line,
        funcName: StaticString = #function
    ) {
        self.kind = kind

        if let classification = classification {
            self.classification = classification
        } else if let classified = kind as? ClassifiedError {
            self.classification = classified.classification
        } else {
            self.classification = .unexpected
        }

        self.callsite = "[\(MuunError.sourcePath(filePath: filename))]:\(line) \(funcName)"
        self.shortCallsite = "\(MuunError.sourceFileName(filePath: filename)) \(funcName)"
        self.stacktrace = Thread.callStackReturnAddresses
    }

    static func sourcePath(filePath: StaticString) -> String {

        let string = filePath.description
        let components = string.components(separatedBy: "/")
        guard let start = components.lastIndex(of: "falcon") else {
            return string
        }

        return components.suffix(from: start.advanced(by: 1)).joined(separator: "/")
    }

    static func sourceFileName(filePath: StaticString) -> String {

        let string = filePath.description
        let components = string.components(separatedBy: "/")
        return components.last ?? "<unknown>"
    }

    public var errorDescription: String? {
        return "\(callsite): \(kind)"
    }

    public var shortDescription: String {
        return "\(shortCallsite): \(kind)"
    }

}

extension MuunError: CustomStringConvertible {

    public var description: String {
        return "MuunError(\(shortDescription))"
    }
}
