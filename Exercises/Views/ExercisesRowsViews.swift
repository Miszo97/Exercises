import SwiftUI

struct RepsExerciseRowView: View {
    var name: String
    var value: String
    
    var body: some View {
        HStack {
            Text(name)
                .fontWeight(.bold)
            + Text(": \(value)")
        }.padding(.horizontal)
    }
}

struct DurationExerciseRowView: View {
    var name: String
    var value: String
    
    var body: some View {
        HStack {
            HStack {
                Text(name)
                    .fontWeight(.bold)
                + Text(": \(value) seconds")
            }
        }.padding(.horizontal)
    }
}

struct AddExerciseRowView: View {
    @State private var toAdd: String
    @FocusState private var isInputActive: Bool
    let name: String
    let onAdd: (Int) async throws -> Void
    let reload: () async -> Void
    @State private var buttonText: String = "Add"

    init(
        name: String,
        initialValue: Int,
        performAdd: @escaping (Int) async throws -> Void,
        reload: @escaping () async -> Void
    ) {
        self.name = name
        self.onAdd = performAdd
        self.reload = reload
        self._toAdd = State(initialValue: String(initialValue))
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(name)
                .fontWeight(.bold)

            HStack(spacing: 8) {
                TextField("Enter a number", text: $toAdd)
                    .keyboardType(.numberPad)
                    .focused($isInputActive)
                    .frame(minWidth: 80)
                    .toolbar {
                        if isInputActive {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isInputActive = false
                                    UserDefaults.standard.set(toAdd, forKey: "exercises_settings_\(name)_to_add")
                                }
                            }
                        }
                    }

                Button(buttonText) {
                    Task {
                        buttonText = "Adding..."
                        defer { buttonText = "Add" }
                        if let value = Int(toAdd) {
                            do {
                                try await onAdd(value)
                                // On success, log timestamp
                                let key = "exercises_logs_\(name)"
                                let nowISO8601 = ISO8601DateFormatter().string(from: Date())
                                var logs = UserDefaults.standard.stringArray(forKey: key) ?? []
                                logs.append(nowISO8601)
                                UserDefaults.standard.set(logs, forKey: key)
                                // Refresh list
                                await reload()
                            } catch {
                                print("Failed to add exercise:", error)
                            }
                        }
                    }
                }
                .bold()
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.accentColor.opacity(0.08)) // lighter, subtle tint
                )
                .foregroundColor(.accentColor)
                .contentShape(Capsule())
                .accessibilityLabel("Add \(name)")
            }
        }
        .padding(.horizontal)
    }
}

struct AddRepsExerciseRowView: View {
    let name: String
    let initialValue: Int
    let reload: () async -> Void
    private let client = ExerciseClient()

    var body: some View {
        AddExerciseRowView(
            name: name,
            initialValue: initialValue,
            performAdd: { value in
                try await client.addRepsExercise(name: name, reps: value)
            },
            reload: reload
        )
    }
}

struct AddDurationExerciseRowView: View {
    let name: String
    let initialValue: Int
    let reload: () async -> Void
    private let client = ExerciseClient()

    var body: some View {
        AddExerciseRowView(
            name: name,
            initialValue: initialValue,
            performAdd: { value in
                try await client.addDurationExercise(name: name, duration: value)
            },
            reload: reload
        )
    }
}

private let previewClient = ExerciseClient()

#Preview {
    Group {
        AddExerciseRowView(
            name: "Push Ups",
            initialValue: 20,
            performAdd: { value in
                try await previewClient.addRepsExercise(name: "Push Ups", reps: value)
            },
            reload: {}
        )
        AddExerciseRowView(
            name: "Plank",
            initialValue: 60,
            performAdd: { value in
                try await previewClient.addDurationExercise(name: "Plank", duration: value)
            },
            reload: {}
        )
        // Wrapper previews
        AddRepsExerciseRowView(name: "Squats", initialValue: 15, reload: {})
        AddDurationExerciseRowView(name: "Wall Sit", initialValue: 45, reload: {})
        
        RepsExerciseRowView(name: "Push Ups", value: "12")
        DurationExerciseRowView(name: "Plank", value: "60")
    }
}
