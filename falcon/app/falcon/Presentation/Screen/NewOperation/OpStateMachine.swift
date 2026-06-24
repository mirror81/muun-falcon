//
//  OpStateMachine.swift
//  falcon
//
//  Created by Juan Pablo Civile on 01/10/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

public struct FeeBumpInfo: Equatable {
    let uuid: String
    let amountInSat: Satoshis
    let refreshPolicy: String
    // Derived from time.Since(CreatedAt) in libwallet, so it changes on every materialization
    // of the same underlying fee bump set. Excluded from equality to keep FeeState comparisons
    // stable across re-computations.
    let secondsSinceLastUpdate: Int64

    public static func == (lhs: FeeBumpInfo, rhs: FeeBumpInfo) -> Bool {
        return lhs.uuid == rhs.uuid
            && lhs.amountInSat == rhs.amountInSat
            && lhs.refreshPolicy == rhs.refreshPolicy
    }
}

enum FeeState: Equatable {
    case finalFee(_ fee: BitcoinAmount, rate: FeeRate, feeBumpInfo: FeeBumpInfo?)
    case feeNeedsChange(displayFee: BitcoinAmount, rate: FeeRate)
    // Consider removing this from here and making this a throw wherever it goes 🤷‍♂️
    case noPossibleFee

    func getFeeAmount() -> BitcoinAmount? {
        switch self {
        case .finalFee(let btcAmount, _, _):
            return btcAmount
        default:
            return nil
        }
    }

    func getFeeBumpInfo() -> FeeBumpInfo? {
        switch self {
        case .finalFee(_, _, let feeBumpInfo):
            return feeBumpInfo
        default:
            return nil
        }
    }

    static func == (lhs: FeeState, rhs: FeeState) -> Bool {
        switch (lhs, rhs) {
        case (
            .finalFee(let lhsFee, let lhsRate, let lhsFeeBumpInfo),
            .finalFee(let rhsFee, let rhsRate, let rhsFeeBumpInfo)
        ):
            return lhsFee.inSatoshis == rhsFee.inSatoshis &&
                    lhsRate == rhsRate &&
                    lhsFeeBumpInfo == rhsFeeBumpInfo
        case (.feeNeedsChange(let lhsFee, let lhsRate), .feeNeedsChange(let rhsFee, let rhsRate)):
            return lhsFee.inSatoshis == rhsFee.inSatoshis && lhsRate == rhsRate
        case (.noPossibleFee, .noPossibleFee):
            return true
        default:
            return false
        }
    }
}

protocol NewOpStateMachineDelegate: BasePresenterDelegate {
    func requestNextStep(_ data: NewOpState)
    func requestFinish(_ operation: Operation)

    func operationCompleted(_ operation: Operation)

    // Errors
    func operationError(_ error: Error)
    func showExchangeRateWindowTooOldError()
    func notEnoughBalance(amountPlusFee: MonetaryAmount, totalBalance: MonetaryAmount)
    func expiredInvoice()
    func invalidAddress()
    func swapError(_ error: NewOpError)
    func amountBelowDust()
    func invoiceMissingAmount()
    func unexpectedError(_ error: Error)

    func setExpires(_ expiresTime: Double)
    func cancel(confirm: Bool)
}

protocol NewOperationTransitions: AnyObject {
    func back()
}

protocol OpStateMachine: NewOperationTransitions {
    func setUp()
    func tearDown()
}

enum NewOpNextStep {
    case view(_ view: MUView, filledData: [MUView])
    case modal(_ viewController: MUViewController)
}

protocol OpViewBuilder {
    func getNextStep(state: NewOpState) -> NewOpNextStep
    func getLoggingData(state: NewOpState) -> (logName: String, logParams: [String: Any]?)?
    func shouldDisplayOneConfNotice(state: NewOpState) -> Bool
}
