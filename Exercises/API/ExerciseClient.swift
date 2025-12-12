import Foundation
import Playgrounds

final class ExerciseClient {
    // Read base URL dynamically from UserDefaults so Settings can change it.
    private var baseURL: String {
        // Fallback to the original production URL if nothing stored.
        UserDefaults.standard.string(forKey: "exercises_base_url") ?? "http://kevin224.mikrus.xyz:40191"
    }

    private let http: HttpClient

    init(http: HttpClient = HttpClient()) {
        self.http = http
    }

    func addRepsExercise(name: String, reps: Int) async throws {
        let urlString = baseURL + "/reps"
        let body: [String: Any] = [
            "name": name,
            "reps": reps
        ]
        let data = try await http.sendPostRequest(url: urlString, body: body)
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response: \(responseString)")
        }
    }

    func addDurationExercise(name: String, duration: Int) async throws {
        let urlString = baseURL + "/duration"
        let body: [String: Any] = [
            "name": name,
            "duration": duration
        ]
        let data = try await http.sendPostRequest(url: urlString, body: body)
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response: \(responseString)")
        }
    }

    func fetchTodayExercises() async throws -> Dictionary<String, Int> {
        let urlString = baseURL + "/today"
        let data = try await http.sendGetRequest(url: urlString)
        
        print("Received data:", String(data: data, encoding: .utf8) ?? "No string")
        
        let decoder = JSONDecoder()
        
        do {
            let wrapped = try decoder.decode(Dictionary<String, Int>.self, from: data)
            return wrapped
        } catch {
            print("Decoding failed. \(error)")
            throw error
        }
    }

    func fetchExerciseEntries(for exerciseName: String, lastDays: Int = 7) async throws -> [Exercise] {
        guard var components = URLComponents(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        components.path = (components.path + "/exercises/\(exerciseName)")
        
        components.queryItems = [
                URLQueryItem(name: "last_days", value: String(lastDays))
            ]

        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        let data = try await http.sendGetRequest(url: url.absoluteString)
        return try JSONDecoder().decode([Exercise].self, from: data)
    }
    
    func fetchTotalReps(for exerciseName: String) async throws -> Int {
        let encoded = exerciseName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? exerciseName
        let urlString = baseURL + "/exercises/\(encoded)" + "/stats"
        let data = try await http.sendGetRequest(url: urlString)
        let decoded = try JSONDecoder().decode(TotalRepsResponse.self, from: data)
        return decoded.total_reps
    }
    
    func fetchTotalDuration(for exerciseName: String) async throws -> Int {
        let encoded = exerciseName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? exerciseName
        let urlString = baseURL + "/exercises/\(encoded)" + "/stats"
        let data = try await http.sendGetRequest(url: urlString)
        let decoded = try JSONDecoder().decode(TotalDurationResponse.self, from: data)
        return decoded.total_duration
    }
    
}


#Playground {
    var components = URLComponents()
    components.host = "example.com"
    components.path = "/test"
    let url = components.url  // nil - no scheme set
}
