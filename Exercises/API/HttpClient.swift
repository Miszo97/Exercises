import Foundation

final class HttpClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func sendGetRequest(url: String) async throws -> Data {
        guard let url = URL(string: url) else {
            throw APIError.invalidURL
        }
        let (data, response) = try await session.data(from: url)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? "No response body"
            print("HTTP ERROR \(http.statusCode): \(body)")
            throw APIError.httpError
        }
        return data
    }

    func sendPostRequest(url: String, body: [String: Any]) async throws -> Data {
        guard let url = URL(string: url) else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            let bodyText = String(data: data, encoding: .utf8) ?? "No response body"
            print("HTTP ERROR \(http.statusCode): \(bodyText)")
            throw APIError.httpError
        }
        return data
    }
}
