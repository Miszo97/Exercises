import SwiftUI

struct RepsExerciseRow: View {
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

struct DurationExerciseRow: View {
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

struct AddExerciseRow: View {
    @State private var toAdd: String
    @FocusState private var isInputActive: Bool
    let name: String
    let performAdd: (Int) async throws -> Void
    @State private var buttonText: String = "Add"

    init(
        name: String,
        initialValue: Int,
        performAdd: @escaping (Int) async throws -> Void
    ) {
        self.name = name
        self.performAdd = performAdd
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
                                try await performAdd(value)
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
    AddExerciseRow(
        name: "Push Ups",
        initialValue: 20,
        performAdd: { value in try await addRepsExercise(name: "Push Ups", reps: value) }
    )
    AddExerciseRow(
        name: "Plank",
        initialValue: 60,
        performAdd: { value in try await addDurationExercise(name: "Plank", duration: value, unit: "seconds") }
    )
    RepsExerciseRow(name: "Push Ups", value: "12")
    DurationExerciseRow(name: "Plank", value: "60")
}
