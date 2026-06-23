//
//  RealTimeDataAction.swift
//  falcon
//
//  Created by Juan Pablo Civile on 20/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift

public typealias FeeConfirmationTargets = (slow: UInt, medium: UInt, fast: UInt)

public class RealTimeDataAction: AsyncAction<RealTimeData> {

    private let houstonService: HoustonService
    private let feeWindowRepository: FeeWindowRepository
    private let exchangeRateWindowRepository: ExchangeRateWindowRepository
    private let blockchainHeightRepository: BlockchainHeightRepository
    private let forwardingPoliciesRepository: ForwardingPolicyRepository
    private let minFeeRateRepository: MinFeeRateRepository
    private let featureFlagsRepository: FeatureFlagsRepository
    private let userRepository: UserRepository

    private let secondsForFreshData: Double = 5 * 60
    // .distantPast ensures the first check after a cold launch always refreshes.
    private var lastSyncTime: Date = .distantPast

    init(
        houstonService: HoustonService,
        feeWindowRepository: FeeWindowRepository,
        exchangeRateWindowRepository: ExchangeRateWindowRepository,
        blockchainHeightRepository: BlockchainHeightRepository,
        forwardingPoliciesRepository: ForwardingPolicyRepository,
        minFeeRateRepository: MinFeeRateRepository,
        featureFlagsRepository: FeatureFlagsRepository,
        userRepository: UserRepository
    ) {

        self.houstonService = houstonService

        self.feeWindowRepository = feeWindowRepository
        self.exchangeRateWindowRepository = exchangeRateWindowRepository
        self.blockchainHeightRepository = blockchainHeightRepository
        self.forwardingPoliciesRepository = forwardingPoliciesRepository
        self.minFeeRateRepository = minFeeRateRepository
        self.featureFlagsRepository = featureFlagsRepository
        self.userRepository = userRepository

        super.init(name: "RealTimeDataAction")
    }

    public func run(forceUpdate: Bool = false) {
        runSingle(fetchRealTimeData(forceUpdate: forceUpdate))
    }

    private func fetchRealTimeData(forceUpdate: Bool = false) -> Single<RealTimeData> {
        if shouldUpdateData() || forceUpdate {
            return houstonService.fetchRealTimeData()
                .do(onSuccess: { (data) in
                    self.exchangeRateWindowRepository.setExchangeRateWindow(data.exchangeRateWindow)
                    self.blockchainHeightRepository.setBlockchainHeight(
                        data.currentBlockchainHeight
                    )
                    self.forwardingPoliciesRepository.store(policies: data.forwardingPolicies)
                    self.featureFlagsRepository.store(flags: data.features)

                    // When the FF is ON, this data will be stored by PreloadFeeDataAction
                    if !data.features.contains(.effectiveFeesCalculation) {
                        self.feeWindowRepository.setFeeWindow(data.feeWindow)
                        self.minFeeRateRepository
                            .store(satsPerWeightUnit: data.minFeeRateInWeightUnits)
                    }

                    self.lastSyncTime = Date()
                })
        } else {
            let realData = RealTimeData(
                feeWindow: feeWindowRepository.getFeeWindow()!,
                exchangeRateWindow: exchangeRateWindowRepository.getExchangeRateWindow()!,
                currentBlockchainHeight: blockchainHeightRepository.getCurrentBlockchainHeight(),
                forwardingPolicies: forwardingPoliciesRepository.fetch(),
                minFeeRateInWeightUnits: NSDecimalNumber(
                    decimal: minFeeRateRepository.fetch().satsPerWeightUnit
                ).doubleValue,
                features: featureFlagsRepository.fetch()
            )
            return Single.just(realData)
        }
    }

    private func shouldUpdateData() -> Bool {
        #if DEBUG
        if ProcessInfo().arguments.contains("testMode") {
            return true
        }
        #endif

        // Refresh if we don't have any cache to fall back to.
        guard exchangeRateWindowRepository.getExchangeRateWindow() != nil,
              feeWindowRepository.getFeeWindow() != nil else {
            return true
        }

        // Compare against the device-local timestamp of the last successful
        // sync. Avoids the previous bug where we compared the device clock
        // against the server-side fetchDate: a device with a skewed clock
        // would produce a negative elapsed time and never refresh.
        let elapsedTime = Date().timeIntervalSince(lastSyncTime)

        // Clock moved backward since lastSyncTime (manual change, NTP
        // correction): treat as stale to recover from a stuck state.
        return elapsedTime < 0 || elapsedTime >= secondsForFreshData
    }
}
