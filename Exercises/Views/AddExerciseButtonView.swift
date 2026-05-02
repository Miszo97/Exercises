import SwiftUI

struct AddExerciseButtonView: View {
    let name: String
    @Binding var toAdd: String
    let onAdd: (Int) async throws -> Void
    let reload: () async -> Void
    @State private var buttonText: String = "Add"
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Button(buttonText) {
            Task {
                buttonText = "Adding..."
                defer { buttonText = "Add" }
                if let value = Int(toAdd) {
                    do {
                        try await onAdd(value)
                        let key = "exercises_logs_\(name)"
                        let nowISO8601 = ISO8601DateFormatter().string(from: Date())
                        var logs = UserDefaults.standard.stringArray(forKey: key) ?? []
                        logs.append(nowISO8601)
                        UserDefaults.standard.set(logs, forKey: key)
                        alertMessage = "\(name) exercise added successfully!"
                        showAlert = true
                        await reload()
                    } catch {
                        alertMessage = "Failed to add exercise: \(error.localizedDescription)"
                        showAlert = true
                        print("Failed to add exercise:", error)
                    }
                } else {
                    alertMessage = "Please enter a valid number"
                    showAlert = true
                }
            }
        }
        .bold()
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.accentColor.opacity(0.08))
        )
        .foregroundColor(.accentColor)
        .contentShape(Capsule())
        .accessibilityLabel("Add \(name)")
        .alert("Exercise Added", isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }
}
