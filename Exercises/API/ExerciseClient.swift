import Foundation

final class ExerciseClient {
    private let baseURL = "https://exercises-581797442525.europe-central2.run.app"

    func addRepsExercise(name: String, reps: Int, unit: String? = nil) async throws {
        let urlString = baseURL + "/reps"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "name": name,
            "reps": reps
        ]
        if let unit = unit {
            body["unit"] = unit
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw APIError.requestFailed
        }

        if let responseString = String(data: data, encoding: .utf8) {
            print("Response: \(responseString)")
        }
    }

    func addDurationExercise(name: String, duration: Int, unit: String? = "seconds") async throws {
        let urlString = baseURL + "/duration"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "name": name,
            "duration": duration
        ]
        if let unit = unit {
            body["unit"] = unit
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw APIError.requestFailed
        }

        if let responseString = String(data: data, encoding: .utf8) {
            print("Response: \(responseString)")
        }
    }

    func fetchTodayExercises() async throws -> [Exercise] {
        let urlString = baseURL + "/today"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? "No response body"
            print("HTTP ERROR \(httpResponse.statusCode): \(body)")
            throw APIError.httpError
        }

        print("Received data:", String(data: data, encoding: .utf8) ?? "No string")

        let decoder = JSONDecoder()

        do {
            let wrapped = try decoder.decode(TodayExercisesResponse.self, from: data)
            return wrapped.exercises
        } catch {
            do {
                let exercises = try decoder.decode([Exercise].self, from: data)
                return exercises
            } catch {
                print("Decoding failed. Neither wrapper nor array matched. Error: \(error)")
                throw error
            }
        }
    }
}
