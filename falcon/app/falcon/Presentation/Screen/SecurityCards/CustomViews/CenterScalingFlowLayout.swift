//
//  CenterScalingFlowLayout.swift
//  falcon
//
//  Created by Federico Jordán on 20/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class CenterScalingFlowLayout: UICollectionViewFlowLayout {

    private let minScale: CGFloat = 0.80
    private let maxScale: CGFloat = 0.95

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { true }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attrs = super.layoutAttributesForElements(in: rect),
              let cv = collectionView else { return nil }

        let centerY = cv.contentOffset.y + cv.bounds.height / 2
        let maxDistance = cv.bounds.height / 2

        return attrs.compactMap { $0.copy() as? UICollectionViewLayoutAttributes }.map { attr in
            let distance = abs(attr.center.y - centerY)
            let t = min(distance / maxDistance, 1)
            let scale = maxScale - (maxScale - minScale) * t
            attr.transform = CGAffineTransform(scaleX: scale, y: scale)
            return attr
        }
    }

    override func targetContentOffset(forProposedContentOffset proposed: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let cv = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposed, withScrollingVelocity: velocity)
        }

        let halfHeight = cv.bounds.height / 2
        let proposedCenterY = proposed.y + halfHeight
        let rect = CGRect(x: 0, y: proposed.y, width: cv.bounds.width, height: cv.bounds.height)

        guard let attrs = super.layoutAttributesForElements(in: rect),
              let closest = attrs.min(by: { abs($0.center.y - proposedCenterY) < abs($1.center.y - proposedCenterY) })
        else { return proposed }

        return CGPoint(x: proposed.x, y: closest.center.y - halfHeight)
    }
}
