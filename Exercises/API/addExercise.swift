import SwiftUI

func addRepsExercise(name: String, reps: Int, unit: String? = nil) async throws {
    let apiURL = "https://exercises-581797442525.europe-central2.run.app/reps"
    
    guard let url = URL(string: apiURL) else {
        throw Err.WrongURL
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
        throw Err.RequestFailed
    }
    
    if let responseString = String(data: data, encoding: .utf8) {
        print("Response: \(responseString)")
    }
}

func addDurationExercise(name: String, duration: Int, unit: String? = "seconds") async throws {
    let apiURL = "https://exercises-581797442525.europe-central2.run.app/duration"
    
    guard let url = URL(string: apiURL) else {
        throw Err.WrongURL
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
        throw Err.RequestFailed
    }
    
    if let responseString = String(data: data, encoding: .utf8) {
        print("Response: \(responseString)")
    }
}
