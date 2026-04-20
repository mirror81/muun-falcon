//
//  UIColor+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 10/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

extension UIColor {

    /// Converts this `UIColor` instance to a 1x1 `UIImage` instance and returns it.
    ///
    /// - Returns: `self` as a 1x1 `UIImage`.
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }

    convenience init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        let v = Int(s, radix: 16) ?? 0
        if s.count == 8 {
            let r = CGFloat((v >> 24) & 0xff) / 255
            let g = CGFloat((v >> 16) & 0xff) / 255
            let b = CGFloat((v >> 8) & 0xff) / 255
            let a = CGFloat(v & 0xff) / 255
            self.init(red: r, green: g, blue: b, alpha: a)
        } else {
            let r = CGFloat((v >> 16) & 0xff) / 255
            let g = CGFloat((v >> 8) & 0xff) / 255
            let b = CGFloat(v & 0xff) / 255
            self.init(red: r, green: g, blue: b, alpha: 1)
        }
    }

}
