import Foundation

enum Err: Error {
    case WrongURL
    case RESPONSE_ERROR
    case RequestFailed
}

struct Response: Decodable {
    var exercise_names: [String]
    var rows: [RowAPI]
}

struct Exercise: Codable {
    let name: String
    let type: String
    let reps: Int?
    let duration: Int?
}

func fetch_today_exercises() async throws -> [Exercise] {
    guard let url = URL(string: api_url) else {
        throw Err.WrongURL
    }

    let (data, response) = try await URLSession.shared.data(from: url)
    
    // Check for HTTP errors
    if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
        let body = String(data: data, encoding: .utf8) ?? "No response body"
        print("HTTP ERROR \(httpResponse.statusCode): \(body)")
        throw Err.RESPONSE_ERROR
    }
    
    // Debug: Print what you actually receive
    print("Received data:", String(data: data, encoding: .utf8) ?? "No string")

    let decoder = JSONDecoder()
    let exercises = try decoder.decode([Exercise].self, from: data) // decode array directly
    return exercises
}
