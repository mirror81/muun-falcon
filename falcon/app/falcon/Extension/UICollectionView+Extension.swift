//
//  UICollectionView+Extension.swift
//  falcon
//
//  Created by Federico Jordán on 16/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

extension UICollectionView {

    func dequeue<T: UICollectionViewCell>(type: T.Type, indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: T.idCell,
            for: indexPath
        ) as? T else {
            fatalError("Could not dequeue cell of type \(T.idCell)")
        }

        return cell
    }

    func register<T: UICollectionViewCell>(type: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.idCell)
    }
}
