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
    var unit: String = "seconds"
    
    var body: some View {
        HStack {
            HStack {
                Text(name)
                    .fontWeight(.bold)
                + Text(": \(value) ") + Text(unit)
            }
        }.padding(.horizontal)
    }
}

struct AddExerciseRowView: View {
    @State private var toAdd: String
    @FocusState private var isInputActive: Bool
    let name: String
    let onAdd: (Int) async throws -> Void
    @State private var buttonText: String = "Add"

    init(
        name: String,
        initialValue: Int,
        performAdd: @escaping (Int) async throws -> Void
    ) {
        self.name = name
        self.onAdd = performAdd
        self._toAdd = State(initialValue: String(initialValue))
    }

    var body: some View {
        HStack {
            Text(name)
                .fontWeight(.bold)
            HStack {
                TextField("Enter a number", text: $toAdd)
                    .keyboardType(.numberPad)
                    .focused($isInputActive)
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
                            } catch {
                                print("Failed to add exercise:", error)
                            }
                        }

                    }
                }
                .bold()
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    AddExerciseRowView(
        name: "Push Ups",
        initialValue: 20,
        performAdd: { value in try await addRepsExercise(name: "Push Ups", reps: value) }
    )
    AddExerciseRowView(
        name: "Plank",
        initialValue: 60,
        performAdd: { value in try await addDurationExercise(name: "Plank", duration: value, unit: "seconds") }
    )
    RepsExerciseRowView(name: "Push Ups", value: "12")
    DurationExerciseRowView(name: "Plank", value: "60")
}
