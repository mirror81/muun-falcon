//
//  SecurityCardProviderInfoTransition.swift
//  falcon
//
//  Created by Federico Jordán on 01/06/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

/// A view controller that can be animated by
/// `SecurityCardProviderInfoTransitionController`. Exposes the target view that
/// will scale and translate from the source pill into its final position.
protocol SecurityCardProviderInfoTransitionable: UIViewController {
    var transitionTargetView: UIView { get }
}

/// Custom modal presentation for the provider info card.
///
/// Animates a `scale + translate` from the source pill to the centered card,
/// combined with an alpha fade. The source pill is left untouched in the nav
/// bar — only the modal card is animated.
final class SecurityCardProviderInfoTransitionController:
    NSObject, UIViewControllerTransitioningDelegate {

    private weak var sourceView: UIView?

    init(sourceView: UIView) {
        self.sourceView = sourceView
        super.init()
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        SecurityCardProviderInfoPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let sourceView else { return nil }
        return SecurityCardProviderInfoAnimator(direction: .present, sourceView: sourceView)
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let sourceView else { return nil }
        return SecurityCardProviderInfoAnimator(direction: .dismiss, sourceView: sourceView)
    }
}

// MARK: - Presentation controller (backdrop)

fileprivate final class SecurityCardProviderInfoPresentationController: UIPresentationController {

    private enum Constants {
        static let backdropMaxAlpha: CGFloat = 0.5
    }

    private let backdrop: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()

    override func presentationTransitionWillBegin() {
        guard let containerView else { return }
        backdrop.frame = containerView.bounds
        backdrop.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.insertSubview(backdrop, at: 0)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackdropTap))
        backdrop.addGestureRecognizer(tap)

        guard let coordinator = presentedViewController.transitionCoordinator else {
            backdrop.alpha = Constants.backdropMaxAlpha
            return
        }
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.backdrop.alpha = Constants.backdropMaxAlpha
        })
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            backdrop.alpha = 0
            return
        }
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.backdrop.alpha = 0
        })
    }

    @objc private func handleBackdropTap() {
        presentedViewController.dismiss(animated: true)
    }
}

// MARK: - Animator

fileprivate final class SecurityCardProviderInfoAnimator:
    NSObject, UIViewControllerAnimatedTransitioning {

    enum Direction {
        case present
        case dismiss
    }

    private enum Constants {
        static let duration: TimeInterval = 0.32
        static let initialScale: CGFloat = 0.2
    }

    private let direction: Direction
    private weak var sourceView: UIView?

    init(direction: Direction, sourceView: UIView) {
        self.direction = direction
        self.sourceView = sourceView
    }

    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
        Constants.duration
    }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        switch direction {
        case .present: animatePresent(using: context)
        case .dismiss: animateDismiss(using: context)
        }
    }

    private func animatePresent(using context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        guard
            let toVC = context.viewController(forKey: .to)
                as? SecurityCardProviderInfoTransitionable,
            let toView = context.view(forKey: .to),
            let sourceView
        else {
            context.completeTransition(false)
            return
        }

        toView.frame = containerView.bounds
        containerView.addSubview(toView)
        toView.layoutIfNeeded()

        let targetView = toVC.transitionTargetView
        targetView.transform = startTransform(
            for: targetView,
            in: containerView,
            sourceView: sourceView
        )
        targetView.alpha = 0

        UIView.animate(
            withDuration: Constants.duration,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0,
            options: .curveEaseOut
        ) {
            targetView.transform = .identity
            targetView.alpha = 1
        } completion: { _ in
            context.completeTransition(!context.transitionWasCancelled)
        }
    }

    private func animateDismiss(using context: UIViewControllerContextTransitioning) {
        guard
            let fromVC = context.viewController(forKey: .from)
                as? SecurityCardProviderInfoTransitionable,
            let sourceView
        else {
            context.completeTransition(false)
            return
        }

        let containerView = context.containerView
        let targetView = fromVC.transitionTargetView
        let endTransform = startTransform(
            for: targetView,
            in: containerView,
            sourceView: sourceView
        )

        UIView.animate(
            withDuration: Constants.duration,
            delay: 0,
            options: .curveEaseIn
        ) {
            targetView.transform = endTransform
            targetView.alpha = 0
        } completion: { _ in
            context.completeTransition(!context.transitionWasCancelled)
        }
    }

    /// Returns the transform that places `targetView` at the source pill's
    /// position, scaled down to roughly the pill's size.
    private func startTransform(
        for targetView: UIView, in containerView: UIView, sourceView: UIView
    ) -> CGAffineTransform {
        let pillCenter = sourceView.convert(
            CGPoint(x: sourceView.bounds.midX, y: sourceView.bounds.midY),
            to: containerView
        )
        let targetCenter = CGPoint(x: targetView.frame.midX, y: targetView.frame.midY)
        let dx = pillCenter.x - targetCenter.x
        let dy = pillCenter.y - targetCenter.y
        return CGAffineTransform.identity
            .translatedBy(x: dx, y: dy)
            .scaledBy(x: Constants.initialScale, y: Constants.initialScale)
    }
}
