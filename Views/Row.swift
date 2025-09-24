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

struct AddRepsExerciseRow: View {
    @State private var toAdd: String = "20"
    @FocusState var isInputActive: Bool
    var name: String
    let onAdd: () async -> Void
    @State var buttonText: String = "Add"

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
                        if let reps = Int(toAdd) {
                            try await addRepsExercise(name: name, reps: reps)
                        }
                        await onAdd()
                        buttonText = "Add"
                    }
                }.bold(true)
            }
        }.padding(.horizontal)
    }
}

struct AddDurationExerciseRow: View {
    @State private var toAdd: String = "60"
    @FocusState var isInputActive: Bool
    var name: String
    let onAdd: () async -> Void
    @State var buttonText: String = "Add"

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
                                }
                            }
                        }
                    }
                Button(buttonText) {
                    Task {
                        buttonText = "Adding..."
                        if let duration = Int(toAdd) {
                            try await addDurationExercise(name: name, duration: duration, unit: "seconds")
                        }
                        await onAdd()
                        buttonText = "Add"
                    }
                }.bold(true)
            }
        }.padding(.horizontal)
    }
}

#Preview {
    AddRepsExerciseRow(name: "Push Ups", onAdd: { print("hello AddRepsExerciseRow") })
    AddDurationExerciseRow(name: "Plank", onAdd: { print("hello AddDurationExerciseRow")})
    RepsExerciseRow(name: "Push Ups", value: "12")
    DurationExerciseRow(name: "Plank", value: "60")
}

