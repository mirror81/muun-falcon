//
//  CountrySelectorViewController.swift
//  falcon
//
//  Created by Federico Jordán on 06/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

protocol CountrySelectorViewControllerDelegate: AnyObject {
    func countrySelectorDidSelect(country: Country)
}

final class CountrySelectorViewController: MUViewController {

    private enum Constants {
        static let rowHeight = MuunTheme.Legacy.s52
    }

    private weak var delegate: CountrySelectorViewControllerDelegate?

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.CountrySelectorViewController.emptyState
        label.textAlignment = .center
        label.font = Constant.Fonts.system(size: .desc)
        label.textColor = MuunTheme.Color.Text.bodySecondary
        return label
    }()
    private var countries: [Country] = []
    private let selectedCountryCode: String
    private lazy var presenter = instancePresenter(CountrySelectorPresenter.init, delegate: self)

    private lazy var alphabeticallyOrderedHeader: UIView = {
        let container = UIView()
        container.backgroundColor = MuunTheme.Color.Surface.background

        let label = UILabel()
        label.text = L10n.CountrySelectorViewController.alphabeticallyOrdered.uppercased()
        label.font = MuunTheme.Font.Body.xs
        label.textColor = MuunTheme.Color.Text.bodySecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: MuunTheme.Spacing.md
            ),
            label.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -MuunTheme.Spacing.md
            ),
            label.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: MuunTheme.Spacing.sm
            ),
            label.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -MuunTheme.Spacing.xs
            )
        ])
        return container
    }()

    override var screenLoggingName: String {
        "security_cards_country_selector"
    }

    init(selectedCountryCode: String, delegate: CountrySelectorViewControllerDelegate) {
        self.selectedCountryCode = selectedCountryCode
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = MuunTheme.Color.Surface.background
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
        setupTableView()
        setupSearchBar()
        presenter.loadData()
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = Constants.rowHeight
        tableView.backgroundColor = MuunTheme.Color.Surface.background
        tableView.registerClass(type: UITableViewCell.self)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupSearchBar() {
        let searchBar = UISearchBar()
        searchBar.tintColor = MuunTheme.Color.Text.action
        searchBar.placeholder = L10n.CountrySelectorViewController.searchPlaceholder
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = MuunTheme.Color.Surface.field
        searchBar.searchTextField.textColor = MuunTheme.Color.Text.bodyPrimary
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
    }

}

// MARK: - CountrySelectorPresenterDelegate

extension CountrySelectorViewController: CountrySelectorPresenterDelegate {

    func update(countries: [Country]) {
        self.countries = countries
        tableView.backgroundView = countries.isEmpty ? emptyLabel : nil
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension CountrySelectorViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(type: UITableViewCell.self, indexPath: indexPath)
        let country = countries[indexPath.row]

        cell.textLabel?.text = "\(country.flag) \(country.name)"
        cell.accessoryType = country.code == selectedCountryCode ? .checkmark : .none
        cell.backgroundColor = MuunTheme.Color.Surface.background

        return cell
    }
}

// MARK: - UITableViewDelegate

extension CountrySelectorViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let country = countries[indexPath.row]
        delegate?.countrySelectorDidSelect(country: country)
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !countries.isEmpty else { return nil }
        return alphabeticallyOrderedHeader
    }

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        countries.isEmpty ? 0 : UITableView.automaticDimension
    }
}

// MARK: - UISearchBarDelegate

extension CountrySelectorViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.filter(searchText: searchText)
    }
}
