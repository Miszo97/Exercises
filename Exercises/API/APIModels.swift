import Foundation

enum APIError: Error {
    case invalidURL
    case httpError
    case requestFailed
}

struct Exercise: Decodable {
    let date: String?
    let name: String
    let reps: Int?
    let duration: Int?
    let unit: String?
}

// Wrapper for { "exercises": [ ... ] }
struct TodayExercisesResponse: Decodable {
    let exercises: [Exercise]
}

// This enum models the two possible row types for UI display.
enum ExerciseRow: Identifiable {
    case reps(name: String, value: String)
    case duration(name: String, value: String)
    
    var id: String {
        switch self {
        case .reps(let name, _): return "reps-\(name)"
        case .duration(let name, _): return "duration-\(name)"
        }
    }
}

struct TodayTableRowResponse: Decodable {
    var date: String
    var values: [String]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        date = try container.decode(String.self)
        values = try container.decode([String].self)
    }
}
