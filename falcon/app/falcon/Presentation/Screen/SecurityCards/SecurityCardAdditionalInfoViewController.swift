//
//  SecurityCardAdditionalInfoViewController.swift
//  falcon
//
//  Created by Federico Jordán on 21/05/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

/// Sheet that surfaces extra context for a security card spec item.
///
/// Generic on purpose: the caller supplies a `ViewModel` with the icon, title
/// and an HTML-encoded body so any spec can opt in without changing this view.
final class SecurityCardAdditionalInfoViewController: UIViewController {

    struct ViewModel {
        let symbolName: String
        let title: String
        let descriptionHTML: String
    }

    private enum Constants {
        static let iconSize: CGFloat = 56
    }

    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MuunTheme.Color.Surface.home
        setupContent()

        let width = UIScreen.main.bounds.width
        view.frame = CGRect(origin: .zero, size: CGSize(width: width, height: 0))
        view.setNeedsLayout()
        view.layoutIfNeeded()
        preferredContentSize = view.systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }

    private func setupContent() {
        let symbolConfig = UIImage.SymbolConfiguration(
            pointSize: Constants.iconSize, weight: .regular
        )
        let icon = UIImageView(
            image: UIImage(systemName: viewModel.symbolName, withConfiguration: symbolConfig)
        )
        icon.tintColor = MuunTheme.Color.Text.bodySecondary
        icon.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = viewModel.title
        titleLabel.font = MuunTheme.Font.Heading.h3
        titleLabel.textColor = MuunTheme.Color.Text.bodyPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let descriptionTextView = makeDescriptionTextView(html: viewModel.descriptionHTML)

        let stack = UIStackView(arrangedSubviews: [icon, titleLabel, descriptionTextView])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = MuunTheme.Spacing.xs
        stack.setCustomSpacing(MuunTheme.Spacing.md, after: titleLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            icon.heightAnchor.constraint(equalToConstant: Constants.iconSize),

            descriptionTextView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),

            stack.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            stack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            stack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            ),
            // Anchored to view.bottomAnchor (not safeArea) so preferredContentSize captures
            // the full intrinsic height including bottom padding for the home indicator.
            stack.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -MuunTheme.Spacing.xl3
            )
        ])
    }

    private func makeDescriptionTextView(html: String) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.linkTextAttributes = [
            .foregroundColor: MuunTheme.Color.Text.action
        ]
        textView.attributedText = attributedDescription(from: html)
        return textView
    }

    private func attributedDescription(from html: String) -> NSAttributedString {
        let fallback = NSAttributedString(string: html)
        guard let data = html.data(using: .utf8) else { return fallback }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        let parsed: NSMutableAttributedString
        do {
            parsed = try NSMutableAttributedString(
                data: data, options: options, documentAttributes: nil
            )
        } catch {
            Logger.log(.err, "Failed to parse spec description HTML: \(error)")
            return fallback
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = MuunTheme.Spacing.xs2
        paragraphStyle.paragraphSpacing = MuunTheme.Spacing.md

        // Apply our base styling to all ranges. Link ranges keep their `.link`
        // attribute, and UITextView's linkTextAttributes overlays the action
        // color on top.
        let fullRange = NSRange(location: 0, length: parsed.length)
        parsed.addAttributes([
            .font: MuunTheme.Font.Body.md,
            .foregroundColor: MuunTheme.Color.Text.bodySecondary,
            .paragraphStyle: paragraphStyle
        ], range: fullRange)

        return parsed
    }
}
