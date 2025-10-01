import Foundation

enum Err: Error {
    case WrongURL
    case RESPONSE_ERROR
    case RequestFailed
}

struct Exercise: Codable {
    let name: String
    let type: String
    let reps: Int?
    let duration: Int?
}

// Wrapper for { "exercises": [ ... ] }
private struct TodayExercisesResponse: Decodable {
    let exercises: [Exercise]
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

    // First try decoding the wrapper { "exercises": [...] }
    do {
        let wrapped = try decoder.decode(TodayExercisesResponse.self, from: data)
        return wrapped.exercises
    } catch {
        // Fallback: try decoding a top-level array [ ... ]
        do {
            let exercises = try decoder.decode([Exercise].self, from: data)
            return exercises
        } catch {
            print("Decoding failed. Neither wrapper nor array matched. Error: \(error)")
            throw error
        }
    }
}
