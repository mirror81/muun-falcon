//
//  MuunAliases.swift
//  falcon
//
//  Semantic design tokens — light/dark resolution lives here.
//  Generated from the shared Figma token library (`alias` collection).
//
//  Do not consume aliases directly from feature code; use `MuunTheme` instead.
//

import UIKit

enum MuunAliases {

    enum Text {
        static let heading = dynamic(light: Palette.black, dark: Palette.white)
        static let bodyPrimary = dynamic(light: Palette.black, dark: Palette.white)
        static let bodySecondary = dynamic(light: Palette.gray300, dark: Palette.gray200)
        static let action = dynamic(light: Palette.blue300, dark: Palette.blue400)
        static let onActionPrimary = Palette.white
        static let onActionSecondary = dynamic(light: Palette.blue300, dark: Palette.blue400)
        static let success = Palette.green300
        static let error = dynamic(light: Palette.red300, dark: Palette.red400)
        static let warning = Palette.yellow300
        static let metal = dynamic(light: Palette.metal800, dark: Palette.metal500)
    }

    enum Surface {
        // surface/home — Figma `platform` mode pinned to iOS values.
        static let home = dynamic(light: Palette.white, dark: Palette.blue700)
        static let background = dynamic(light: Palette.white, dark: Palette.iosDark)
        static let field = dynamic(light: Palette.gray100, dark: Palette.blue730)
        static let overlay = Palette.black50
        static let actionPrimary = dynamic(light: Palette.blue300, dark: Palette.blue400)
        static let actionSecondary = dynamic(light: Palette.white, dark: Palette.blue730)
        static let sheetIllustration = dynamic(light: Palette.gray100, dark: Palette.blue730)
        static let cardPrimary = dynamic(light: Palette.blue300Alpha5, dark: Palette.blue400Alpha5)
    }

    enum Icon {
        static let primary = dynamic(light: Palette.gray300, dark: Palette.gray200)
    }

    enum Border {
        static let primary = dynamic(light: Palette.gray200, dark: Palette.gray400)
        static let selected = dynamic(light: Palette.blue300Alpha55, dark: Palette.blue400Alpha55)
        static let header = dynamic(light: Palette.gray200, dark: Palette.blue500)
    }

    enum Pill {
        // pill/text dark resolves to text/body/primary (white in dark mode).
        static let text = dynamic(light: Palette.blue730, dark: Palette.white)
        static let border = dynamic(light: Palette.gray400, dark: Palette.gray200)
    }

    enum FontWeight {
        static let textDefault: UIFont.Weight = .regular
        static let textStrong: UIFont.Weight = .medium
        static let headingDefault: UIFont.Weight = .medium
        static let headingSubtle: UIFont.Weight = .regular
    }

    // MARK: - Helpers

    private typealias Palette = MuunPrimitives.Palette

    private static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        }
    }
}
