//
//  PinView.swift
//  falcon
//
//  Created by Manu Herrera on 22/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

protocol PinViewDelegate: AnyObject {
    func setDelete(enabled: Bool)
    func animationStarted()
    func animationEnded()
}

@IBDesignable
class PinView: MUView {

    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var pinViewContainer: UIView!

    private var pinViews: [UIView] = []

    var filledPins = 0
    weak var delegate: PinViewDelegate?

    static let filledColor = Asset.Colors.muunBlue.color
    static let unfilledColor = Asset.Colors.background.color
    static let successColor = Asset.Colors.muunGreen.color
    static let failedColor = Asset.Colors.muunRed.color

    private let pinBulletViewWidth = 12.0

    public func setUp(length: Int) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        pinViews.removeAll()

        for _ in 0..<length {
            let view = UIView(
                frame: CGRect(x: 0, y: 0, width: pinBulletViewWidth, height: pinBulletViewWidth)
            )
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: pinBulletViewWidth).isActive = true
            view.widthAnchor.constraint(equalToConstant: pinBulletViewWidth).isActive = true

            view.circleView()
            view.backgroundColor = PinView.unfilledColor
            view.layer.borderWidth = 1
            view.layer.borderColor = PinView.filledColor.cgColor

            stackView.addArrangedSubview(view)
            pinViews.append(view)
        }
    }

    public func colorNextPin() {
        filledPins += 1
        if filledPins < pinViews.count {
            delegate?.setDelete(enabled: true)

            UIView.animate(withDuration: 0.25) {
                self.pinViews[self.filledPins - 1].backgroundColor = PinView.filledColor
            }
        }
    }

    public func erasePin() {
        if filledPins < pinViews.count {
            delegate?.setDelete(enabled: true)

            UIView.animate(withDuration: 0.25) {
                self.pinViews[self.filledPins - 1].backgroundColor = PinView.unfilledColor
            }
        }

        filledPins -= 1

        if filledPins == 0 {
            delegate?.setDelete(enabled: false)
        }
    }

    public func pinValidationFeedback(isValid: Bool) {
        let color = isValid
            ? PinView.successColor
            : PinView.failedColor

        delegate?.animationStarted()

        UIView.animate(
            withDuration: 0.25,
            animations: {

            for view in self.pinViews {
                view.backgroundColor = color
                view.layer.borderColor = color.cgColor
            }

            }, completion: { (_) in
                if !isValid {
                    self.pinViewContainer.shake(
                        completion: {
                            self.clearInput()
                        }
                    )
                }
            }
        )
    }

    public func clearInput() {
        delegate?.animationStarted()

        UIView.animate(withDuration: 0.25, animations: {
            for view in self.pinViews {
                view.backgroundColor = PinView.unfilledColor
                view.layer.borderColor = PinView.filledColor.cgColor
            }
        }, completion: { (_) in
            self.delegate?.animationEnded()

        })
    }

}
