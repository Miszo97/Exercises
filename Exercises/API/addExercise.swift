//
//  File 2.swift
//  Exercises
//
//  Created by Artur Spek on 14/09/2025.
//


import SwiftUI

func addExercise(name: String, duration: Int? = nil, reps: Int? = nil, unit: String? = nil) async throws {
    guard let url = URL(string: api_url) else {
        throw Err.WrongURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    var body: [String: Any] = [
        "name": name,
    ]
    
    if duration != nil {
        body["duration"] = duration
    }
    
    if reps != nil {
        body["reps"] = reps
    }
    
    if unit != nil {
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
