//
//  RegularTrackerViewController.swift
//  Tracker
//
//  Created by Vadim Nuretdinov on 16.07.2023.
//

import UIKit

// MARK: - Protocols

protocol UpdateSubtitleDelegate: AnyObject {
    func updateCategorySubtitle(from string: String?, at indexPath: IndexPath?)
    func updateScheduleSubtitle(from weekday: [Weekday]?, at selectedWeekday: [Int: Bool])
}

// MARK: - Regular Tracker ViewController Class

final class RegularTrackerViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var trackerTitleTextField: UITextField = {
        let textField = UITextField()
        textField.configure(with: "Введите название трекера")
        textField.delegate = self
        return textField
    }()
    
    private lazy var symbolsConstraintLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = UIColor.TrackerColor.red
        label.font = UIFont.TrackerFont.regular17
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 75
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(
            RegularTrackerTableViewSubtitleCell.self,
            forCellReuseIdentifier: RegularTrackerTableViewSubtitleCell.reuseIdentifier
        )
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        view.distribution = .fillProportionally
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.configure(with: .cancelButton, for: "Отменить")
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.configure(with: .createButton, for: "Создать")
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private let dataManager = DataManager.shared
    private let titleCells = ["Категория", "Расписание"]
    private let colors = [
        UIColor.TrackerColor.colorSelection1, UIColor.TrackerColor.colorSelection5,
        UIColor.TrackerColor.colorSelection9, UIColor.TrackerColor.colorSelection16
    ]
    private let emojies = [
        "❤️", "🚴‍♂️", "✍️", "👨🏻‍⚕️", "👻", "🥶"
    ]
    
    private var trackerTitle = ""
    private var categorySubtitle = ""
    private var scheduleSubtitle: [Weekday] = []
    private var selectedWeekdays: [Int: Bool] = [:]
    
    private var tableViewDataSource: RegularTrackerTableViewDataSource?
    private var tableViewDelegate: RegularTrackerTableViewDelegate?
    
    var indexCategory: IndexPath?
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.TrackerColor.white
        
        tableViewDataSource = RegularTrackerTableViewDataSource(viewController: self)
        tableViewDelegate = RegularTrackerTableViewDelegate(viewController: self)
        
        addSubviews()
    }
    
    // MARK: - Methods
    
    private func addSubviews() {
        addTopNavigationLabel()
        addStackView()
        addTableView()
        addButtonsStackView()
    }
    
    private func createTracker() {
        if let text = trackerTitleTextField.text, !text.isEmpty {
            trackerTitle = text
        }

        let newTracker = Tracker(
            id: UUID(),
            title: trackerTitle,
            color: colors.randomElement() ?? UIColor(),
            emoji: emojies.randomElement() ?? String(),
            schedule: scheduleSubtitle
        )
        
        let categoryTitle = categorySubtitle
        
        if let index = dataManager.categories.firstIndex(where: {
            $0.title == categoryTitle
        }) {
            let existingCategory = dataManager.categories[index]
            let updatedTrackers = existingCategory.trackers + [newTracker]
            let updatedCategory = TrackerCategory(
                title: existingCategory.title,
                trackers: updatedTrackers
            )
            
            dataManager.categories[index] = updatedCategory
        } else {
            let newCategory = TrackerCategory(
                title: categoryTitle,
                trackers: [newTracker]
            )
            
            dataManager.add(categories: [newCategory])
        }
    }
    
    func getTitles() -> [String] {
        titleCells
    }
    
    func getCategorySubtitle() -> String {
        categorySubtitle
    }
    
    func getSchedule() -> [Weekday] {
        scheduleSubtitle
    }
    
    func getSelectedWeekdays() -> [Int: Bool] {
        selectedWeekdays
    }
    
    func getScheduleSubtitle(from selectedWeekdays: [Weekday]) -> String {
        if selectedWeekdays == Weekday.allCases {
            return "Каждый день"
        } else {
            return selectedWeekdays.compactMap { $0.weekdayShortName }.joined(separator: ", ")
        }
    }
    
    // MARK: - Objective-C methods
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        createTracker()
        delegate?.updateTrackers()
        
        var currentViewController = self.presentingViewController
        while currentViewController is UINavigationController {
            currentViewController = currentViewController?.presentingViewController
        }
        currentViewController?.dismiss(animated: true)
    }
}

// MARK: - Add subviews

private extension RegularTrackerViewController {
    
    func addTopNavigationLabel() {
        title = "Новая привычка"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.TrackerFont.medium16,
            .foregroundColor: UIColor.TrackerColor.black
        ]
    }
    
    func addStackView() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(trackerTitleTextField)
        stackView.addArrangedSubview(symbolsConstraintLabel)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    func addTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 150),
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    func addButtonsStackView() {
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
        
        NSLayoutConstraint.activate([
            buttonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
}

// MARK: - TextFieldDelegate methods

extension RegularTrackerViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = textField.text, !text.isEmpty else {
            return true
        }
        
        let newLength = text.count + string.count - range.length
        symbolsConstraintLabel.isHidden = (newLength <= 38)
        
        if newLength >= 1 {
            createButton.isEnabled = true
            createButton.backgroundColor = UIColor.TrackerColor.black
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = UIColor.TrackerColor.gray
        }
        
        return newLength <= 38
    }
}

// MARK: - Delegate methods

extension RegularTrackerViewController: UpdateSubtitleDelegate {
    
    func updateCategorySubtitle(from string: String?, at indexPath: IndexPath?) {
        categorySubtitle = string ?? ""
        indexCategory = indexPath
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func updateScheduleSubtitle(from weekday: [Weekday]?, at selectedWeekday: [Int : Bool]) {
        scheduleSubtitle = weekday ?? []
        selectedWeekdays = selectedWeekday
        
        let indexPath = IndexPath(row: 1, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
