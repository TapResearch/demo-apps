//
//  QualificationSurveyView.swift
//  IntegrationDemo_SwiftUI
//
//  Created by Jeroen Verbeek on 09/08/26.
//

import SwiftUI
import TapResearchSDK

/// ---------------------------------------------------------------------------------------------
/// ---------------------------------------------------------------------------------------------
public struct TRQualificationSurveyView: View {
	
	@StateObject private var model: TRQualificationViewModel

	private let onExit: () -> Void
	private let onComplete: (TRProfileResponse) -> Void

	@State private var dateWasEdited: Set<Int> = []

	/// ---------------------------------------------------------------------------------------------
	public init(
		response: TRProfileResponse,
		submitHandler: @escaping TRQualificationViewModel.SubmitHandler,
		onExit: @escaping () -> Void,
		onComplete: @escaping (TRProfileResponse) -> Void
	) {
		_model = StateObject(
			wrappedValue: TRQualificationViewModel(
				response: response,
				submitHandler: submitHandler
			)
		)
		self.onExit = onExit
		self.onComplete = onComplete
	}

	/// ---------------------------------------------------------------------------------------------
	public var body: some View {
		VStack(spacing: 0) {
			header
			Divider()

			if model.isComplete {
				completeView
			} else if let question = model.currentQuestion {
				ScrollView {
					VStack(alignment: .leading, spacing: 20) {
						questionHeader(question)
						errorView(for: question)
						questionControl(question)
					}
					.padding(24)
				}

				Divider()
				navigationBar(question)
			} else {
				completeView
			}
		}
		.alert(
			"Unable to submit answers",
			isPresented: Binding(
				get: { model.generalError != nil },
				set: { if !$0 { model.clearGeneralError() } }
			),
			actions: {
				Button("OK") { model.clearGeneralError() }
			},
			message: {
				Text(model.generalError ?? "An unknown error occurred.")
			}
		)
	}

	/// ---------------------------------------------------------------------------------------------
	private var header: some View {
		VStack(spacing: 10) {
			HStack {
				Text("About You")
					.font(.headline)

				Spacer()

				Button("Exit", role: .cancel) {
					onExit()
				}
			}

			if !model.questions.isEmpty {
				HStack {
					Text("Question \(model.currentIndex + 1) of \(model.questions.count)")
						.font(.caption)
						.foregroundStyle(.secondary)

					Spacer()
				}

				ProgressView(
					value: Double(model.currentIndex + 1),
					total: Double(max(model.questions.count, 1))
				)
			}
		}
		.padding()
	}

	/// ---------------------------------------------------------------------------------------------
	private var completeView: some View {
		VStack(spacing: 18) {
			Spacer()
			Image(systemName: "checkmark.circle.fill")
				.font(.system(size: 48))
				.foregroundStyle(.green)

			Text("You're all set")
				.font(.title2.bold())

			Text("Your profiling answers have been accepted.")
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)

			Button("Done") {
				onComplete(model.response)
			}
			.buttonStyle(.borderedProminent)
			Spacer()
		}
		.padding(32)
	}

	/// ---------------------------------------------------------------------------------------------
	@ViewBuilder
	private func questionHeader(_ question: TRProfileQuestion) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(question.questionText)
				.font(.title2.weight(.semibold))
				.frame(maxWidth: .infinity, alignment: .leading)

			if let subtext = question.questionSubtext, !subtext.isEmpty {
				Text(subtext)
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
		}
	}

	/// ---------------------------------------------------------------------------------------------
	@ViewBuilder
	private func errorView(for question: TRProfileQuestion) -> some View {
		if let message = model.errors[question.questionId] {
			HStack(alignment: .top, spacing: 10) {
				Image(systemName: "exclamationmark.triangle.fill")
				Text(message)
					.font(.subheadline)
			}
			.foregroundStyle(.red)
			.padding(12)
			.frame(maxWidth: .infinity, alignment: .leading)
			.background(Color.red.opacity(0.08))
			.clipShape(RoundedRectangle(cornerRadius: 10))
		}
	}

	/// ---------------------------------------------------------------------------------------------
	@ViewBuilder
	private func questionControl(_ question: TRProfileQuestion) -> some View {
		switch question.answerType {
			case "date":
				dateControl(question)

			case "zip_code":
				zipCodeControl(question)

			case "single_select":
				if question.qualificationAnswers.count > 10 {
					longSingleSelectControl(question)
				} else {
					singleSelectControl(question)
				}

			case "multi_select":
				multiSelectControl(question)

			default:
				Text("Unsupported question type: \(question.answerType)")
					.foregroundStyle(.secondary)
		}
	}

	/// ---------------------------------------------------------------------------------------------
	private func dateControl(_ question: TRProfileQuestion) -> some View {
		let defaultDate = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()

		let binding = Binding<Date>(
			get: {
				if case .date(let date) = model.answers[question.questionId] {
					return date
				}
				return defaultDate
			},
			set: { newValue in
				dateWasEdited.insert(question.questionId)
				model.answers[question.questionId] = .date(newValue)
			}
		)

		return VStack(alignment: .leading, spacing: 8) {
			DatePicker(
				"Date of birth",
				selection: binding,
				in: ...Date(),
				displayedComponents: .date
			)
			.datePickerStyle(.graphical)
			.labelsHidden()

			if !dateWasEdited.contains(question.questionId) && model.answers[question.questionId] == nil {
				Text("Choose your date of birth to continue.")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
	}

	/// ---------------------------------------------------------------------------------------------
	private func zipCodeControl(_ question: TRProfileQuestion) -> some View {
		let zipBinding = Binding<String>(
			get: { zipDraft(for: question) },
			set: { newValue in
				model.answers[question.questionId] = .zipCode(value: newValue)
			}
		)

		return VStack(alignment: .leading, spacing: 12) {
			TextField("ZIP or postal code", text: zipBinding)
				.textFieldStyle(.roundedBorder)
				.textContentType(.postalCode)
				.textInputAutocapitalization(.characters)
				.autocorrectionDisabled()
		}
	}

	/// ---------------------------------------------------------------------------------------------
	private func singleSelectControl(_ question: TRProfileQuestion) -> some View {
		VStack(spacing: 10) {
			ForEach(question.qualificationAnswers, id: \.preCode) { option in
				let selected = selectedSinglePreCode(for: question) == option.preCode

				Button {
					model.answers[question.questionId] = .single(preCode: option.preCode)
				} label: {
					HStack(spacing: 12) {
						Image(systemName: selected ? "checkmark.circle.fill" : "circle")
							.font(.title3)
						Text(option.optionText)
							.foregroundStyle(.primary)
							.multilineTextAlignment(.leading)
						Spacer()
					}
					.padding(14)
					.frame(maxWidth: .infinity)
					.background(selected ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.08))
					.clipShape(RoundedRectangle(cornerRadius: 12))
				}
				.buttonStyle(.plain)
			}
		}
	}

	/// ---------------------------------------------------------------------------------------------
	private func longSingleSelectControl(_ question: TRProfileQuestion) -> some View {
		let binding = Binding<String>(
			get: { selectedSinglePreCode(for: question) ?? "" },
			set: { model.answers[question.questionId] = .single(preCode: $0) }
		)

		return Picker("Select an answer", selection: binding) {
			Text("Select an answer").tag("")
			ForEach(question.qualificationAnswers, id: \.preCode) { option in
				Text(option.optionText).tag(option.preCode)
			}
		}
		.pickerStyle(.menu)
		.padding(14)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(Color.secondary.opacity(0.08))
		.clipShape(RoundedRectangle(cornerRadius: 12))
	}

	/// ---------------------------------------------------------------------------------------------
	private func multiSelectControl(_ question: TRProfileQuestion) -> some View {
		VStack(spacing: 10) {
			ForEach(question.qualificationAnswers, id: \.preCode) { option in
				let selected = selectedMultiplePreCodes(for: question).contains(option.preCode)

				Button {
					var values = selectedMultiplePreCodes(for: question)
					if selected {
						values.remove(option.preCode)
					} else {
						values.insert(option.preCode)
					}
					model.answers[question.questionId] = .multiple(preCodes: values)
				} label: {
					HStack(spacing: 12) {
						Image(systemName: selected ? "checkmark.square.fill" : "square")
							.font(.title3)
						Text(option.optionText)
							.foregroundStyle(.primary)
							.multilineTextAlignment(.leading)
						Spacer()
					}
					.padding(14)
					.frame(maxWidth: .infinity)
					.background(selected ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.08))
					.clipShape(RoundedRectangle(cornerRadius: 12))
				}
				.buttonStyle(.plain)
			}
		}
	}

	/// ---------------------------------------------------------------------------------------------
	private func navigationBar(_ question: TRProfileQuestion) -> some View {
		HStack {
			Button("Back") {
				model.goBack()
			}
			.disabled(model.currentIndex == 0 || model.isSubmitting)

			Spacer()

			if model.isSubmitting {
				ProgressView()
			}

			Button(model.isLastQuestion ? "Submit" : "Continue") {
				if model.isLastQuestion {
					Task {
						if let updated = await model.submitCurrentAnswers(), model.isComplete {
							onComplete(updated)
						}
					}
				} else {
					model.goForward()
				}
			}
			.buttonStyle(.borderedProminent)
			.disabled(!model.hasAnswer(for: question) || model.isSubmitting)
		}
		.padding()
	}

	/// ---------------------------------------------------------------------------------------------
	private func selectedSinglePreCode(for question: TRProfileQuestion) -> String? {
		guard case .single(let preCode) = model.answers[question.questionId] else { return nil }
		return preCode
	}

	/// ---------------------------------------------------------------------------------------------
	private func selectedMultiplePreCodes(for question: TRProfileQuestion) -> Set<String> {
		guard case .multiple(let preCodes) = model.answers[question.questionId] else { return [] }
		return preCodes
	}

	/// ---------------------------------------------------------------------------------------------
	private func zipDraft(for question: TRProfileQuestion) -> String {
		guard case .zipCode(let value) = model.answers[question.questionId] else {
			return ""
		}
		return value
	}
	
}
