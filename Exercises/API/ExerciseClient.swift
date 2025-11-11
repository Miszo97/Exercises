import Foundation

final class ExerciseClient {
    private let baseURL = "http://kevin224.mikrus.xyz:20224"
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

    func fetchExerciseEntries(for exerciseName: String) async throws -> [Exercise] {
        let encoded = exerciseName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? exerciseName
        let urlString = baseURL + "/exercises/\(encoded)"
        let data = try await http.sendGetRequest(url: urlString)
        let exercises = try JSONDecoder().decode([Exercise].self, from: data)
        return exercises
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
