//
//  MarketplaceViewController.swift
//  falcon
//
//  Created by Federico Jordán on 23/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class MarketplaceViewController: MUViewController {

    private let providerTabsView = SecurityCardProvidersTabsView()
    private var selectedProviderIndex = 0
    private lazy var presenter = instancePresenter(MarketplacePresenter.init, delegate: self)
    private var cachedProviders: [SecurityCardProvider] = []
    private var pages: [UIViewController] = []
    private lazy var pageVC: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        vc.dataSource = self
        vc.delegate = self
        return vc
    }()
    private var currentIndex: Int = 0

    override var screenLoggingName: String {
        "security_cards_marketplace"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        presenter.loadData()
    }

    // Interface

    private func setupView() {
        title = L10n.MarketplaceViewController.title

        setupCountryBarButton()
        setupProviderTabs()
        setupPages()
    }

    private func setupPages() {
        addChild(pageVC)
        let pageContainer = UIView()
        pageContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageContainer)
        pageContainer.addSubview(pageVC.view)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false

        pageVC.didMove(toParent: self)

        NSLayoutConstraint.activate([
            pageContainer.topAnchor.constraint(equalTo: providerTabsView.bottomAnchor, constant: 12),
            pageContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            pageVC.view.topAnchor.constraint(equalTo: pageContainer.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: pageContainer.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: pageContainer.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: pageContainer.bottomAnchor)
        ])
    }

    private func setupProviderTabs() {
        view.addSubview(providerTabsView)
        providerTabsView.translatesAutoresizingMaskIntoConstraints = false
        providerTabsView.delegate = self

        NSLayoutConstraint.activate([
            providerTabsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            providerTabsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            providerTabsView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: .verticalRowMargin
            ),
            providerTabsView.heightAnchor.constraint(equalToConstant: securityCardProvidersTabsViewHeight)
        ])
    }

    private func setupCountryBarButton() {
        let countryButtonItem = UIBarButtonItem(
            title: "AR",
            style: .plain,
            target: self,
            action: #selector(MarketplaceViewController.didTapCountry)
        )
        countryButtonItem.accessibilityIdentifier = "Select Country"
        navigationItem.rightBarButtonItem = countryButtonItem
    }

    // Actions

    @objc
    private func didTapCountry() {
        // TODO: implement country selection
    }

}

// MARK: - MarketplacePresenterDelegate

extension MarketplaceViewController: MarketplacePresenterDelegate {
    func update(providers: [SecurityCardProvider]) {
        cachedProviders = providers
        providerTabsView.configure(securityCardProviders: providers, selectedIndex: selectedProviderIndex)

        pages = providers.map { SecurityCardsProviderCarouselViewController(provider: $0, delegate: self) }
        guard let first = pages.first else { return }
        pageVC.setViewControllers([first], direction: .forward, animated: false)
        currentIndex = 0
    }
}

// MARK: - SecurityCardProvidersTabsViewDelegate

extension MarketplaceViewController: SecurityCardProvidersTabsViewDelegate {
    func didSelectProvider(at index: Int) {
        providerTabsView.setSelectedIndex(index, animated: true)
        selectedProviderIndex = index

        guard index < pages.count else { return }
        let direction: UIPageViewController.NavigationDirection = index >= currentIndex ? .forward : .reverse
        pageVC.setViewControllers([pages[index]], direction: direction, animated: true)
        currentIndex = index
    }
}

// MARK: - UIPageViewController DataSource/Delegate

extension MarketplaceViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController), idx - 1 >= 0 else { return nil }
        return pages[idx - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController), idx + 1 < pages.count else { return nil }
        return pages[idx + 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let current = pageViewController.viewControllers?.first,
              let idx = pages.firstIndex(of: current) else { return }
        currentIndex = idx
        selectedProviderIndex = currentIndex
        providerTabsView.setSelectedIndex(currentIndex, animated: true)
    }
}

// MARK: - SecurityCardsProviderCarouselViewControllerDelegate

extension MarketplaceViewController: SecurityCardsProviderCarouselViewControllerDelegate {
    func carouselDidSelectCard(provider: SecurityCardProvider, card: SecurityCard) {
        // TODO: handle card selection
    }
}

private let securityCardProvidersTabsViewHeight: CGFloat = 52
