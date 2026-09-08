import Foundation
import Combine
import TapResearchSDK

/// ---------------------------------------------------------------------------------------------
/// ---------------------------------------------------------------------------------------------
@MainActor
public final class TRQualificationViewModel: ObservableObject {

	public typealias SubmitHandler = ([TRProfileAnswer]) async throws -> TRProfileResponse

	@Published public private(set) var response: TRProfileResponse
	@Published public private(set) var currentIndex: Int = 0
	@Published public private(set) var errors: [Int: String] = [:]
	@Published public private(set) var isSubmitting = false
	@Published public private(set) var generalError: String?
	@Published public var answers: [Int: TRQualificationDraftAnswer] = [:]

	private let submitHandler: SubmitHandler

	/// ---------------------------------------------------------------------------------------------
	public init(response: TRProfileResponse, submitHandler: @escaping SubmitHandler) {

		self.response = response
		self.submitHandler = submitHandler
		self.errors = Self.makeErrors(from: response)
	}

	/// ---------------------------------------------------------------------------------------------
	public var questions: [TRProfileQuestion] {
		response.qualifications
	}

	/// ---------------------------------------------------------------------------------------------
	public var currentQuestion: TRProfileQuestion? {
		guard questions.indices.contains(currentIndex) else { return nil }

		return questions[currentIndex]
	}


	/// ---------------------------------------------------------------------------------------------
	public var isLastQuestion: Bool {
		!questions.isEmpty && currentIndex == questions.count - 1
	}

	/// ---------------------------------------------------------------------------------------------
	public var isComplete: Bool {
		response.isProfiled || questions.isEmpty
	}

	/// ---------------------------------------------------------------------------------------------
	public func goBack() {
		guard currentIndex > 0, !isSubmitting else { return }

		currentIndex -= 1
	}

	/// ---------------------------------------------------------------------------------------------
	public func goForward() {
		guard currentIndex + 1 < questions.count, !isSubmitting else { return }

		currentIndex += 1
	}

	/// ---------------------------------------------------------------------------------------------
	public func hasAnswer(for question: TRProfileQuestion) -> Bool {
		guard let answer = answers[question.questionId] else { return false }

		switch answer {
			case .date:
				return true

			case .zipCode(let value):
				return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

			case .single(let preCode):
				return !preCode.isEmpty

			case .multiple(let preCodes):
				return !preCodes.isEmpty
		}
	}

	/// ---------------------------------------------------------------------------------------------
	/// Submits every locally answered question that is still present in the
	/// server-provided qualification list.
	///
	/// The returned TRProfileResponse becomes the new source of truth:
	/// accepted questions disappear, invalid questions remain, and errors are
	/// attached to the returned questions.
	@discardableResult
	public func submitCurrentAnswers() async -> TRProfileResponse? {
		guard !isSubmitting else { return nil }

		let currentQuestions = Dictionary(
			uniqueKeysWithValues: questions.map { ($0.questionId, $0) }
		)

		let apiAnswers: [TRProfileAnswer] = answers
			.compactMap { questionID, draft in
				guard let question = currentQuestions[questionID] else { return nil }
				return makeAPIAnswer(question: question, draft: draft)
			}

		guard !apiAnswers.isEmpty else { return nil }

		isSubmitting = true
		generalError = nil

		defer { isSubmitting = false }

		do {
			let updatedResponse = try await submitHandler(apiAnswers)
			apply(updatedResponse)
			return updatedResponse
		} catch {
			generalError = error.localizedDescription
			return nil
		}
	}

	/// ---------------------------------------------------------------------------------------------
	public func clearGeneralError() {
		generalError = nil
	}

	/// ---------------------------------------------------------------------------------------------
	private func apply(_ updatedResponse: TRProfileResponse) {

		let returnedIDs = Set(updatedResponse.qualifications.map(\.questionId))

		// Questions omitted by the server were accepted, so their local drafts
		// are no longer needed. Returned/invalid answers remain populated.
		answers = answers.filter { returnedIDs.contains($0.key) }

		response = updatedResponse
		errors = Self.makeErrors(from: updatedResponse)

		// Land on the first invalid question. If there are no explicit errors,
		// start at the first remaining question.
		if let errorIndex = updatedResponse.qualifications.firstIndex(where: {
			errors[$0.questionId] != nil
		}) {
			currentIndex = errorIndex
		} else {
			currentIndex = 0
		}
	}

	/// ---------------------------------------------------------------------------------------------
	private func makeAPIAnswer(question: TRProfileQuestion, draft: TRQualificationDraftAnswer) -> TRProfileAnswer? {

		switch draft {
			case .date(let date):
				return TRProfileAnswer.answer(
					questionId: question.questionId,
					answer: Self.apiDateFormatter.string(from: date)
				)

			case .zipCode(let value):
				let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
				guard !trimmed.isEmpty else { return nil }

				return TRProfileAnswer.answer(
					questionId: question.questionId,
					answer: trimmed
				)

			case .single(let preCode):
				guard !preCode.isEmpty else { return nil }
				return TRProfileAnswer.answer(
					questionId: question.questionId,
					answer: preCode
				)

			case .multiple(let preCodes):
				guard !preCodes.isEmpty else { return nil }
				return TRProfileAnswer.answer(
					questionId: question.questionId,
					answers: preCodes.sorted()
				)
		}
	}

	/// ---------------------------------------------------------------------------------------------
	private static func makeErrors(from response: TRProfileResponse) -> [Int: String] {

		var result: [Int: String] = [:]

		// Per-question error, when provided by the API.
		for question in response.qualifications {
			if let previousError = question.previousError, !previousError.isEmpty {
				result[question.questionId] = previousError
			}
		}

//		// Top-level result.errors wins if both are present.
//		if let answerResult = response.result {
//			for (questionID, message) in answerResult.errors {
//				if let id = Int(questionID), !message.isEmpty {
//					result[id] = message
//				}
//			}
//		}

		return result
	}

	/// ---------------------------------------------------------------------------------------------
	private static let apiDateFormatter: DateFormatter = {

		let formatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .gregorian)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()
	
}
