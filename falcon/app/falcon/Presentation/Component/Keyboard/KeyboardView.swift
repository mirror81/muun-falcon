//
//  KeyboardView.swift
//  falcon
//
//  Created by Manu Herrera on 22/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

protocol KeyboardViewDelegate: AnyObject {
    func onNumberPressed(number: String)
    func onErasePressed()
    func onBiometricsPressed()
}

@IBDesignable
class KeyboardView: MUView {

    @IBOutlet private weak var eraseView: UIView!
    @IBOutlet private weak var eraseImageView: UIImageView!

    @IBOutlet private var numberViews: [UIView]!
    @IBOutlet private var numberLabels: [UILabel]!
    @IBOutlet private var lettersLabels: [UILabel]!

    @IBOutlet private weak var biometricsView: UIView!
    @IBOutlet private weak var biometricsImageView: UIImageView!

    weak var delegate: KeyboardViewDelegate?

    // Provides haptic feedback when keyboard button is pressed
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    public var isEraseEnabled: Bool {
        get { return eraseImageView.isUserInteractionEnabled }
        set { setEraseEnabled(newValue) }
    }

    public var isEnabled: Bool {
        get { return self.isUserInteractionEnabled }
        set { setKeyboardEnabled(newValue) }
    }

    override func setUp() {
        setUpLabels()

        // Warm up haptic engine to ensure feedback works on first tap
        impactFeedback.prepare()

        addNumberViewActions()
        addDeleteAction()
        addBiometricsAction()

        makeViewTestable()
    }

    fileprivate func setUpLabels() {
        for label in numberLabels {
            label.textColor = Asset.Colors.title.color
            label.font = Constant.Fonts.system(size: .h2)
        }

        for label in lettersLabels {
            label.textColor = Asset.Colors.title.color
            label.font = Constant.Fonts.system(size: .helper)
        }
    }

    fileprivate func addNumberViewActions() {
        for view in numberViews {
            view.isAccessibilityElement = true
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(createLongPressGesture(action: .keyboardViewTouched))
        }
    }

    fileprivate func addDeleteAction() {
        eraseView.isUserInteractionEnabled = true
        eraseView.addGestureRecognizer(createLongPressGesture(action: .eraseViewTouched))
    }

    fileprivate func addBiometricsAction() {
        biometricsView.isUserInteractionEnabled = true
        biometricsView.addGestureRecognizer(createLongPressGesture(action: .biometricsViewTouched))
    }

    private func createLongPressGesture(action: Selector) -> UILongPressGestureRecognizer {
        let longPress = UILongPressGestureRecognizer(target: self, action: action)
        longPress.minimumPressDuration = 0
        return longPress
    }

    @objc fileprivate func viewTouched(withSender sender: UILongPressGestureRecognizer) {
        guard let view = sender.view else { return }

        handleButtonTouched(sender) {
            if let number = view.accessibilityLabel {
                delegate?.onNumberPressed(number: number)
            }
        }
    }

    @objc fileprivate func eraseViewTouched(_ sender: UILongPressGestureRecognizer) {
        handleButtonTouched(sender) {
            delegate?.onErasePressed()
        }
    }

    @objc fileprivate func biometricsViewTouched(_ sender: UILongPressGestureRecognizer) {
        handleButtonTouched(sender) {
            delegate?.onBiometricsPressed()
        }
    }

    private func handleButtonTouched(
        _ sender: UILongPressGestureRecognizer,
        completion: () -> Void
    ) {
        switch sender.state {
        case .began:
            // Trigger haptic immediately on touch down
            impactFeedback.impactOccurred()

        case .ended:
            completion()

        default:
            break
        }
    }

    fileprivate func setEraseEnabled(_ isEnabled: Bool) {

        eraseImageView.isUserInteractionEnabled = isEnabled
        eraseView.isUserInteractionEnabled = isEnabled

        let nextAlphaValue: CGFloat = isEnabled
            ? 1.0
            : 0.25

        UIView.animate(withDuration: 0.2) {
            self.eraseImageView.alpha = nextAlphaValue
        }

    }

    fileprivate func setKeyboardEnabled(_ isEnabled: Bool) {

        self.isUserInteractionEnabled = isEnabled

        let nextAlphaValue: CGFloat = isEnabled
            ? 1.0
            : 0.25

        for view in numberViews {
            view.alpha = nextAlphaValue
        }

    }

    func setupBiometrics(status: BiometricsStatus) {
        switch status {
        case .enabledFaceID:
            biometricsView.isHidden = false
            biometricsImageView.image = .faceID
        case .enabledTouchID:
            biometricsView.isHidden = false
            biometricsImageView.image = .touchID
        default:
            biometricsView.isHidden = true
        }
    }
}

extension KeyboardView: UITestablePage {
    typealias UIElementType = UIElements.CustomViews.KeyboardViewPage

    func makeViewTestable() {
        self.makeViewTestable(self.numberViews[0], using: .number1)
        self.makeViewTestable(self.numberViews[1], using: .number2)
        self.makeViewTestable(self.numberViews[2], using: .number3)
        self.makeViewTestable(self.numberViews[3], using: .number4)
        self.makeViewTestable(self.numberViews[4], using: .number5)
        self.makeViewTestable(self.numberViews[5], using: .number6)
        self.makeViewTestable(self.numberViews[6], using: .number7)
        self.makeViewTestable(self.numberViews[7], using: .number8)
        self.makeViewTestable(self.numberViews[8], using: .number9)
        self.makeViewTestable(self.numberViews[9], using: .number0)
        self.makeViewTestable(self.eraseView, using: .erase)
    }

}

fileprivate extension Selector {

    static let keyboardViewTouched =
        #selector(KeyboardView.viewTouched(withSender:))

    static let eraseViewTouched =
        #selector(KeyboardView.eraseViewTouched)

    static let biometricsViewTouched =
        #selector(KeyboardView.biometricsViewTouched)
}

private extension UIImage {
    static let faceID = UIImage(systemName: "faceid")!
    static let touchID = UIImage(systemName: "touchid")!
}
