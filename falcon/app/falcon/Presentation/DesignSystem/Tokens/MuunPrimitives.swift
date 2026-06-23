//
//  MuunPrimitives.swift
//  falcon
//
//  Primitive design tokens — the raw palette and scale.
//  Generated from the shared Figma token library (`primitive` collection).
//
//  Do not consume primitives directly from feature code; use `MuunTheme` instead.
//

import UIKit

enum MuunPrimitives {

    enum Palette {
        // Blues
        static let blue800        = Asset.Colors.Primitives.blue800.color
        static let blue730        = Asset.Colors.Primitives.blue730.color
        static let blue700        = Asset.Colors.Primitives.blue700.color
        static let blue600        = Asset.Colors.Primitives.blue600.color
        static let blue500        = Asset.Colors.Primitives.blue500.color
        static let blue400        = Asset.Colors.Primitives.blue400.color
        static let blue300        = Asset.Colors.Primitives.blue300.color
        static let blue200        = Asset.Colors.Primitives.blue200.color
        static let blue100        = Asset.Colors.Primitives.blue100.color
        static let blue300Alpha5  = Asset.Colors.Primitives.blue300Alpha5.color
        static let blue400Alpha5  = Asset.Colors.Primitives.blue400Alpha5.color
        static let blue300Alpha55 = Asset.Colors.Primitives.blue300Alpha55.color
        static let blue400Alpha55 = Asset.Colors.Primitives.blue400Alpha55.color

        // Reds
        static let red600 = Asset.Colors.Primitives.red600.color
        static let red500 = Asset.Colors.Primitives.red500.color
        static let red400 = Asset.Colors.Primitives.red400.color
        static let red300 = Asset.Colors.Primitives.red300.color
        static let red200 = Asset.Colors.Primitives.red200.color
        static let red100 = Asset.Colors.Primitives.red100.color

        // Greens
        static let green600 = Asset.Colors.Primitives.green600.color
        static let green500 = Asset.Colors.Primitives.green500.color
        static let green400 = Asset.Colors.Primitives.green400.color
        static let green300 = Asset.Colors.Primitives.green300.color
        static let green200 = Asset.Colors.Primitives.green200.color
        static let green100 = Asset.Colors.Primitives.green100.color

        // Yellows
        static let yellow600 = Asset.Colors.Primitives.yellow600.color
        static let yellow500 = Asset.Colors.Primitives.yellow500.color
        static let yellow400 = Asset.Colors.Primitives.yellow400.color
        static let yellow300 = Asset.Colors.Primitives.yellow300.color
        static let yellow200 = Asset.Colors.Primitives.yellow200.color
        static let yellow100 = Asset.Colors.Primitives.yellow100.color

        // Oranges
        static let orange600 = Asset.Colors.Primitives.orange600.color
        static let orange500 = Asset.Colors.Primitives.orange500.color
        static let orange400 = Asset.Colors.Primitives.orange400.color
        static let orange300 = Asset.Colors.Primitives.orange300.color
        static let orange200 = Asset.Colors.Primitives.orange200.color
        static let orange100 = Asset.Colors.Primitives.orange100.color

        // Grays
        static let gray500 = Asset.Colors.Primitives.gray500.color
        static let gray400 = Asset.Colors.Primitives.gray400.color
        static let gray300 = Asset.Colors.Primitives.gray300.color
        static let gray200 = Asset.Colors.Primitives.gray200.color
        static let gray100 = Asset.Colors.Primitives.gray100.color

        // Metals
        static let metal100 = Asset.Colors.Primitives.metal100.color
        static let metal200 = Asset.Colors.Primitives.metal200.color
        static let metal300 = Asset.Colors.Primitives.metal300.color
        static let metal400 = Asset.Colors.Primitives.metal400.color
        static let metal500 = Asset.Colors.Primitives.metal500.color
        static let metal600 = Asset.Colors.Primitives.metal600.color
        static let metal700 = Asset.Colors.Primitives.metal700.color
        static let metal800 = Asset.Colors.Primitives.metal800.color

        // Neutrals
        static let black   = Asset.Colors.Primitives.black.color
        static let black50 = Asset.Colors.Primitives.black50.color
        static let white   = Asset.Colors.Primitives.white.color

        // Foundation
        static let iosDark = Asset.Colors.Primitives.iosDark.color
    }

    /// Scale step values (raw points). Use the `MuunTheme.spacing` aliases instead of these
    /// directly.
    enum Scale {
        static let   s0: CGFloat = 0
        static let  s25: CGFloat = 1
        static let  s50: CGFloat = 2
        static let s100: CGFloat = 4
        static let s200: CGFloat = 8
        static let s300: CGFloat = 12
        static let s400: CGFloat = 16
        static let s500: CGFloat = 20
        static let s600: CGFloat = 24
        static let s700: CGFloat = 28
        static let s800: CGFloat = 32
    }
}
