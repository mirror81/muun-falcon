//
//  SlidesViewConfiguration.swift
//  falcon
//
//  Created by Juan Pablo Civile on 27/10/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation
import UIKit

struct SlidesViewConfiguration {
    struct Slide {
        let title: String
        let image: ImageAsset
        let description: String
    }

    let title: String?
    let finish: String
    let slides: [Slide]
    let screenEvent: String
    let abortTapped: (SlidesViewController) -> ()
    let finishTapped: (SlidesViewController) -> ()
}
