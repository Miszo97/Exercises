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

// MARK: - Stats responses

struct TotalRepsResponse: Decodable {
    let total_reps: Int
}

struct TotalDurationResponse: Decodable {
    let total_duration: Int
}

