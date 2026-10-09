//
//  TRQualificationViewController.swift
//  IntegrationDemo_Swift_UIKit
//
//  Created by Jeroen Verbeek on 10/09/26.
//

import UIKit
import TapResearchSDK

@MainActor
public final class TRQualificationViewController: UIViewController {

	public typealias SubmitHandler = ([TRProfileAnswer]) async throws -> TRProfileResponse
	public typealias ExitHandler = () -> Void
	public typealias CompletionHandler = (TRProfileResponse) -> Void

	public private(set) var response: TRProfileResponse

	private let submitHandler: SubmitHandler
	private let exitHandler: ExitHandler?
	private let completionHandler: CompletionHandler?

	private var currentIndex = 0
	private var isSubmitting = false
	private let wasCompleteWhenPresented: Bool
	private var hasDeliveredInitialCompletion = false

	/// questionId -> Date, String, or Set<String> (pre-codes).
	private var draftAnswers: [Int: Any] = [:]
	private var questionErrors: [Int: String] = [:]

	private let titleLabel = UILabel()
	private let progressLabel = UILabel()
	private let progressView = UIProgressView(progressViewStyle: .default)
	private let exitButton = UIButton(type: .system)

	private let scrollView = UIScrollView()
	private let contentStack = UIStackView()

	private let bottomBar = UIView()
	private let backButton = UIButton(type: .system)
	private let continueButton = UIButton(type: .system)
	private let spinner = UIActivityIndicatorView(style: .medium)

	public init(response: TRProfileResponse, submitHandler: @escaping SubmitHandler, onExit: ExitHandler? = nil, onComplete: CompletionHandler? = nil) {
		self.response = response
		self.submitHandler = submitHandler
		self.exitHandler = onExit
		self.completionHandler = onComplete
		self.questionErrors = Self.errors(from: response)
		self.wasCompleteWhenPresented = response.isProfiled || response.qualifications.isEmpty
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		buildChrome()
		render()
	}

	public override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// If the API said this user was already profiled before this controller
		// was presented, there is nothing useful for the questionnaire to show.
		// Deliver completion once and let the host dismiss/continue immediately.
		if wasCompleteWhenPresented && !hasDeliveredInitialCompletion {
			hasDeliveredInitialCompletion = true
			completionHandler?(response)
		}
	}

	// MARK: - Layout

	private func buildChrome() {
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.font = .preferredFont(forTextStyle: .headline)
		titleLabel.text = "About You"

		exitButton.translatesAutoresizingMaskIntoConstraints = false
		exitButton.setTitle("Exit", for: .normal)
		exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)

		progressLabel.translatesAutoresizingMaskIntoConstraints = false
		progressLabel.font = .preferredFont(forTextStyle: .caption1)
		progressLabel.textColor = .secondaryLabel

		progressView.translatesAutoresizingMaskIntoConstraints = false

		let topSeparator = UIView()
		topSeparator.translatesAutoresizingMaskIntoConstraints = false
		topSeparator.backgroundColor = .separator

		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.keyboardDismissMode = .interactive

		contentStack.translatesAutoresizingMaskIntoConstraints = false
		contentStack.axis = .vertical
		contentStack.spacing = 20
		contentStack.alignment = .fill
		contentStack.distribution = .fill
		scrollView.addSubview(contentStack)

		bottomBar.translatesAutoresizingMaskIntoConstraints = false
		bottomBar.backgroundColor = .systemBackground

		let bottomSeparator = UIView()
		bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
		bottomSeparator.backgroundColor = .separator
		bottomBar.addSubview(bottomSeparator)

		backButton.translatesAutoresizingMaskIntoConstraints = false
		backButton.setTitle("Back", for: .normal)
		backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
		bottomBar.addSubview(backButton)

		continueButton.translatesAutoresizingMaskIntoConstraints = false
		continueButton.setTitle("Continue", for: .normal)
		continueButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
		continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
		bottomBar.addSubview(continueButton)

		spinner.translatesAutoresizingMaskIntoConstraints = false
		spinner.hidesWhenStopped = true
		bottomBar.addSubview(spinner)

		view.addSubview(titleLabel)
		view.addSubview(exitButton)
		view.addSubview(progressLabel)
		view.addSubview(progressView)
		view.addSubview(topSeparator)
		view.addSubview(scrollView)
		view.addSubview(bottomBar)

		let safe = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: safe.topAnchor, constant: 16),
			titleLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),

			exitButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
			exitButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),

			progressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
			progressLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
			progressLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),

			progressView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 8),
			progressView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
			progressView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),

			topSeparator.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 14),
			topSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			topSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			topSeparator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),

			scrollView.topAnchor.constraint(equalTo: topSeparator.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

			contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
			contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
			contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
			contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),

			bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			bottomBar.heightAnchor.constraint(equalToConstant: 76 + view.safeAreaInsets.bottom),

			bottomSeparator.topAnchor.constraint(equalTo: bottomBar.topAnchor),
			bottomSeparator.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor),
			bottomSeparator.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor),
			bottomSeparator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),

			backButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 20),
			backButton.centerYAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 38),

			continueButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
			continueButton.centerYAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 38),

			spinner.trailingAnchor.constraint(equalTo: continueButton.leadingAnchor, constant: -10),
			spinner.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor)
		])
	}

	// MARK: - Rendering

	private var isComplete: Bool {
		response.isProfiled || response.qualifications.isEmpty
	}

	private var currentQuestion: TRProfileQuestion? {
		guard response.qualifications.indices.contains(currentIndex) else { return nil }
		return response.qualifications[currentIndex]
	}

	private func render() {
		contentStack.arrangedSubviews.forEach {
			contentStack.removeArrangedSubview($0)
			$0.removeFromSuperview()
		}

		guard !isComplete, let question = currentQuestion else {
			renderComplete()
			return
		}

		let count = response.qualifications.count
		progressLabel.text = "Question \(currentIndex + 1) of \(count)"
		progressView.progress = count > 0 ? Float(currentIndex + 1) / Float(count) : 0
		progressLabel.isHidden = false
		progressView.isHidden = false
		bottomBar.isHidden = false

		let questionLabel = makeLabel(
			text: question.questionText,
			font: .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .semibold),
			color: .label
		)
		contentStack.addArrangedSubview(questionLabel)

		if let subtext = question.questionSubtext, !subtext.isEmpty {
			contentStack.addArrangedSubview(makeLabel(
				text: subtext,
				font: .preferredFont(forTextStyle: .subheadline),
				color: .secondaryLabel
			))
		}

		if let message = questionErrors[question.questionId], !message.isEmpty {
			contentStack.addArrangedSubview(makeErrorView(message: message))
		}

		switch question.answerType {
			case "date":
				renderDateQuestion(question)
			case "zip_code":
				renderZipQuestion(question)
			case "single_select":
				if question.qualificationAnswers.count > 10 {
					renderLongSingleSelectQuestion(question)
				} else {
					renderSingleSelectQuestion(question)
				}
			case "multi_select":
				renderMultiSelectQuestion(question)
			default:
				contentStack.addArrangedSubview(makeLabel(
					text: "Unsupported question type: \(question.answerType)",
					font: .preferredFont(forTextStyle: .body),
					color: .secondaryLabel
				))
		}

		let isLast = currentIndex == count - 1
		continueButton.setTitle(isLast ? "Submit" : "Continue", for: .normal)
		updateNavigationState()

		// render() can run before the first layout pass (including from viewDidLoad).
		// Force the newly-added arranged subviews through layout now so the scroll
		// content size is valid immediately.
		contentStack.setNeedsLayout()
		view.setNeedsLayout()
		view.layoutIfNeeded()
	}

	private func renderComplete() {
		progressLabel.isHidden = true
		progressView.isHidden = true
		bottomBar.isHidden = true

		let image = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
		image.translatesAutoresizingMaskIntoConstraints = false
		image.contentMode = .scaleAspectFit
		image.tintColor = .systemGreen
		image.heightAnchor.constraint(equalToConstant: 52).isActive = true
		contentStack.addArrangedSubview(image)

		let heading = makeLabel(
			text: "You're all set",
			font: .preferredFont(forTextStyle: .title2),
			color: .label
		)
		heading.textAlignment = .center
		contentStack.addArrangedSubview(heading)

		let message = makeLabel(
			text: "Your profiling answers have been accepted.",
			font: .preferredFont(forTextStyle: .body),
			color: .secondaryLabel
		)
		message.textAlignment = .center
		contentStack.addArrangedSubview(message)

		let done = UIButton(type: .system)
		done.setTitle("Done", for: .normal)
		done.titleLabel?.font = .preferredFont(forTextStyle: .headline)
		done.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
		done.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
		contentStack.addArrangedSubview(done)
	}

	private func renderDateQuestion(_ question: TRProfileQuestion) {
		let picker = UIDatePicker()
		picker.translatesAutoresizingMaskIntoConstraints = false
		picker.datePickerMode = .date
		picker.maximumDate = Date()
		if #available(iOS 14.0, *) {
			picker.preferredDatePickerStyle = .inline
		}

		if let draft = draftAnswers[question.questionId] as? Date {
			picker.date = draft
		} else {
			picker.date = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
		}

		picker.tag = question.questionId
		picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
		contentStack.addArrangedSubview(picker)

		if draftAnswers[question.questionId] == nil {
			contentStack.addArrangedSubview(makeLabel(
				text: "Choose your date of birth to continue.",
				font: .preferredFont(forTextStyle: .caption1),
				color: .secondaryLabel
			))
		}
	}

	private func renderZipQuestion(_ question: TRProfileQuestion) {
		let field = UITextField()
		field.borderStyle = .roundedRect
		field.placeholder = "ZIP or postal code"
		field.textContentType = .postalCode
		field.autocorrectionType = .no
		field.autocapitalizationType = .allCharacters
		field.returnKeyType = .done
		field.delegate = self
		field.tag = question.questionId
		field.text = draftAnswers[question.questionId] as? String
		field.addTarget(self, action: #selector(zipChanged(_:)), for: .editingChanged)
		field.heightAnchor.constraint(equalToConstant: 44).isActive = true
		contentStack.addArrangedSubview(field)
	}

	private func renderSingleSelectQuestion(_ question: TRProfileQuestion) {
		let selected = draftAnswers[question.questionId] as? String
		for option in question.qualificationAnswers {
			let button = makeOptionButton(
				text: option.optionText,
				selected: option.preCode == selected,
				multi: false
			)
			button.tag = question.questionId
			button.accessibilityIdentifier = option.preCode
			button.addTarget(self, action: #selector(singleOptionTapped(_:)), for: .touchUpInside)
			contentStack.addArrangedSubview(button)
		}
	}

	private func renderLongSingleSelectQuestion(_ question: TRProfileQuestion) {
		let selectedCode = draftAnswers[question.questionId] as? String
		let selectedText = question.qualificationAnswers.first(where: { $0.preCode == selectedCode })?.optionText

		let button = UIButton(type: .system)
		button.tag = question.questionId
		button.setTitle(selectedText ?? "Select an answer", for: .normal)
		button.contentHorizontalAlignment = .left
		button.titleLabel?.numberOfLines = 0
		button.layer.cornerRadius = 10
		button.layer.borderWidth = 1
		button.layer.borderColor = UIColor.separator.cgColor
		button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
		button.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
		button.addTarget(self, action: #selector(longSingleTapped(_:)), for: .touchUpInside)
		contentStack.addArrangedSubview(button)
	}

	private func renderMultiSelectQuestion(_ question: TRProfileQuestion) {
		let selected = draftAnswers[question.questionId] as? Set<String> ?? []
		for option in question.qualificationAnswers {
			let button = makeOptionButton(
				text: option.optionText,
				selected: selected.contains(option.preCode),
				multi: true
			)
			button.tag = question.questionId
			button.accessibilityIdentifier = option.preCode
			button.addTarget(self, action: #selector(multiOptionTapped(_:)), for: .touchUpInside)
			contentStack.addArrangedSubview(button)
		}
	}

	// MARK: - Actions

	@objc private func exitTapped() {
		exitHandler?()
	}

	@objc private func doneTapped() {
		completionHandler?(response)
	}

	@objc private func backTapped() {
		guard currentIndex > 0, !isSubmitting else { return }
		currentIndex -= 1
		render()
		scrollView.setContentOffset(.zero, animated: false)
	}

	@objc private func continueTapped() {
		guard let question = currentQuestion,
			  hasAnswer(for: question),
			  !isSubmitting else { return }

		let isLast = currentIndex == response.qualifications.count - 1
		if isLast {
			submitAnswers()
		} else {
			currentIndex += 1
			render()
			scrollView.setContentOffset(.zero, animated: false)
		}
	}

	@objc private func dateChanged(_ sender: UIDatePicker) {
		draftAnswers[sender.tag] = sender.date
		updateNavigationState()
	}

	@objc private func zipChanged(_ sender: UITextField) {
		draftAnswers[sender.tag] = sender.text ?? ""
		updateNavigationState()
	}

	@objc private func singleOptionTapped(_ sender: UIButton) {
		guard let preCode = sender.accessibilityIdentifier else { return }
		draftAnswers[sender.tag] = preCode
		render()
	}

	@objc private func multiOptionTapped(_ sender: UIButton) {
		guard let preCode = sender.accessibilityIdentifier else { return }

		var selected = draftAnswers[sender.tag] as? Set<String> ?? []
		if selected.contains(preCode) {
			selected.remove(preCode)
		} else {
			selected.insert(preCode)
		}
		draftAnswers[sender.tag] = selected
		render()
	}

	@objc private func longSingleTapped(_ sender: UIButton) {
		guard let question = response.qualifications.first(where: { $0.questionId == sender.tag }) else { return }

		let optionsController = TRQualificationOptionsViewController(
			options: question.qualificationAnswers,
			selectedPreCode: draftAnswers[question.questionId] as? String
		) { [weak self] option in
			guard let self else { return }
			self.draftAnswers[question.questionId] = option.preCode
			self.render()
		}

		if let navigationController {
			navigationController.pushViewController(optionsController, animated: true)
		} else {
			let navigation = UINavigationController(rootViewController: optionsController)
			present(navigation, animated: true)
		}
	}

	// MARK: - Submission

	private func submitAnswers() {
		let apiAnswers = response.qualifications.compactMap { question -> TRProfileAnswer? in
			guard let draft = draftAnswers[question.questionId] else { return nil }
			return apiAnswer(for: question, draft: draft)
		}

		guard !apiAnswers.isEmpty else { return }

		isSubmitting = true
		spinner.startAnimating()
		updateNavigationState()

		Task { @MainActor [weak self] in
			guard let self else { return }

			do {
				let updatedResponse = try await submitHandler(apiAnswers)
				isSubmitting = false
				spinner.stopAnimating()
				apply(updatedResponse: updatedResponse)
			} catch {
				isSubmitting = false
				spinner.stopAnimating()
				updateNavigationState()
				presentSubmissionError(error.localizedDescription)
			}
		}
	}

	private func apiAnswer(for question: TRProfileQuestion, draft: Any) -> TRProfileAnswer? {
		switch question.answerType {
			case "date":
				guard let date = draft as? Date else { return nil }
				return TRProfileAnswer.answer(
					questionId: question.questionId,
					answer: Self.apiDateString(from: date)
				)

			case "zip_code":
				guard let value = draft as? String else { return nil }
				let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
				guard !trimmed.isEmpty else { return nil }
				// ZIP/postal answers no longer require country_code.
				return TRProfileAnswer.answer(questionId: question.questionId, answer: trimmed)

			case "single_select":
				guard let preCode = draft as? String, !preCode.isEmpty else { return nil }
				return TRProfileAnswer.answer(questionId: question.questionId, answer: preCode)

			case "multi_select":
				guard let preCodes = draft as? Set<String>, !preCodes.isEmpty else { return nil }
				return TRProfileAnswer.answer(questionId: question.questionId, answers: preCodes.sorted())

			default:
				return nil
		}
	}

	private func apply(updatedResponse: TRProfileResponse) {
		let returnedQuestionIDs = Set(updatedResponse.qualifications.map(\.questionId))

		// Any question omitted by the new response was accepted, so its draft can go away.
		draftAnswers = draftAnswers.filter { returnedQuestionIDs.contains($0.key) }

		response = updatedResponse
		questionErrors = Self.errors(from: updatedResponse)
		currentIndex = 0

		if let firstErrorIndex = updatedResponse.qualifications.firstIndex(where: {
			questionErrors[$0.questionId] != nil
		}) {
			currentIndex = firstErrorIndex
		}

		render()
		scrollView.setContentOffset(.zero, animated: false)
	}

	// MARK: - State

	private func hasAnswer(for question: TRProfileQuestion) -> Bool {
		guard let answer = draftAnswers[question.questionId] else { return false }

		if answer is Date { return true }
		if let string = answer as? String {
			return !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		}
		if let values = answer as? Set<String> {
			return !values.isEmpty
		}
		return false
	}

	private func updateNavigationState() {
		backButton.isEnabled = currentIndex > 0 && !isSubmitting
		continueButton.isEnabled = currentQuestion.map(hasAnswer(for:)) == true && !isSubmitting
		exitButton.isEnabled = true
	}

	private static func errors(from response: TRProfileResponse) -> [Int: String] {
		var result: [Int: String] = [:]
		// Per-question error, when provided by the API.
		for question in response.qualifications {
			if let previousError = question.previousError, !previousError.isEmpty {
				result[question.questionId] = previousError
			}
		}
		return result
	}

	// MARK: - UI helpers

	private func makeLabel(text: String, font: UIFont, color: UIColor) -> UILabel {
		let label = UILabel()
		label.text = text
		label.font = font
		label.textColor = color
		label.numberOfLines = 0
		label.adjustsFontForContentSizeCategory = true
		return label
	}

	private func makeErrorView(message: String) -> UIView {
		let container = UIView()
		container.backgroundColor = UIColor.systemRed.withAlphaComponent(0.08)
		container.layer.cornerRadius = 10

		let icon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
		icon.translatesAutoresizingMaskIntoConstraints = false
		icon.tintColor = .systemRed
		container.addSubview(icon)

		let label = makeLabel(
			text: message,
			font: .preferredFont(forTextStyle: .subheadline),
			color: .systemRed
		)
		label.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(label)

		NSLayoutConstraint.activate([
			icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
			icon.topAnchor.constraint(equalTo: container.topAnchor, constant: 13),
			icon.widthAnchor.constraint(equalToConstant: 18),
			icon.heightAnchor.constraint(equalToConstant: 18),

			label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
			label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
			label.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
			label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
		])

		return container
	}

	private func makeOptionButton(text: String, selected: Bool, multi: Bool) -> UIButton {
		let button = UIButton(type: .system)
		let symbol: String
		if multi {
			symbol = selected ? "checkmark.square.fill" : "square"
		} else {
			symbol = selected ? "checkmark.circle.fill" : "circle"
		}

		button.setImage(UIImage(systemName: symbol), for: .normal)
		button.setTitle(text, for: .normal)
		button.contentHorizontalAlignment = .left
		button.titleLabel?.numberOfLines = 0
		button.titleLabel?.font = .preferredFont(forTextStyle: .body)
		button.tintColor = .systemBlue
		button.backgroundColor = selected
		? UIColor.systemBlue.withAlphaComponent(0.10)
		: UIColor.secondarySystemBackground.withAlphaComponent(0.8)
		button.layer.cornerRadius = 12
		button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
		button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
		button.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
		return button
	}

	private func presentSubmissionError(_ message: String) {
		let alert = UIAlertController(
			title: "Unable to submit answers",
			message: message,
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}

	private static func apiDateString(from date: Date) -> String {
		let formatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .gregorian)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter.string(from: date)
	}
}

// MARK: - UITextFieldDelegate

extension TRQualificationViewController: UITextFieldDelegate {
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

// MARK: - Long single-select list

@MainActor
private final class TRQualificationOptionsViewController: UITableViewController {

	private let options: [TRProfileAnswerOption]
	private let selectedPreCode: String?
	private let selection: (TRProfileAnswerOption) -> Void

	init(
		options: [TRProfileAnswerOption],
		selectedPreCode: String?,
		selection: @escaping (TRProfileAnswerOption) -> Void
	) {
		self.options = options
		self.selectedPreCode = selectedPreCode
		self.selection = selection
		super.init(style: .insetGrouped)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Select an answer"
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OptionCell")
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		options.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
		let option = options[indexPath.row]
		cell.textLabel?.text = option.optionText
		cell.textLabel?.numberOfLines = 0
		cell.accessoryType = option.preCode == selectedPreCode ? .checkmark : .none
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		selection(options[indexPath.row])
		navigationController?.popViewController(animated: true)
	}
}
