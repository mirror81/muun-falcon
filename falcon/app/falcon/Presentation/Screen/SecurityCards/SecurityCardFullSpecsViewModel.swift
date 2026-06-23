//
//  SecurityCardFullSpecsViewModel.swift
//  falcon
//
//  Created by Federico Jordán on 20/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

struct SecurityCardFullSpecsViewModel {
    let title: String
    let providerColor: UIColor
    let imageName: String
    let heightMm: String
    let widthMm: String
    let sections: [SecurityCardSpecsListView.ViewModel]
}
