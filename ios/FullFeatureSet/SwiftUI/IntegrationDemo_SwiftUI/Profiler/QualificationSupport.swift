import Foundation


/// Local UI state only. Nothing here is sent directly to the API.
public enum TRQualificationDraftAnswer: Equatable {
    case date(Date)
    case zipCode(value: String)
    case single(preCode: String)
    case multiple(preCodes: Set<String>)
}
