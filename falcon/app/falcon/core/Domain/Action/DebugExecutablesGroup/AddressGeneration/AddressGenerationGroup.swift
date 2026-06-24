//
//  AddressGenerationGroup.swift
//  Muun
//
//  Created by Lucas Serruya on 23/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

class AddressGenerationGroup: BaseDebugExecutablesGroup {
    init() {
        super.init(
            category: "Address generation",
            executables: [
                CopyRandomAddressDebugExecutable(),
                CopyRandomInvoiceDebugExecutable()
            ]
        )
    }
}
