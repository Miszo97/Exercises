//
//  ExercisesListSettingsView.swift
//  Exercises
//
//  Created by Artur Spek on 31/10/2025.
//

import SwiftUI

struct ExercisesListSettingsView: View {
    @State private var newExerciseName: String = ""
    @State private var selectedType: AddableExerciseType = .reps
    @State private var exercises: [String] = []
    @State private var typesByName: [String: String] = [:] // name -> "reps" | "duration"

    private let storageKey = "exercises_settings_list"
    private let typesKey = "exercises_settings_types"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                TextField("Add exercise", text: $newExerciseName)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)

                Picker("Type", selection: $selectedType) {
                    Text("Reps").tag(AddableExerciseType.reps)
                    Text("Duration").tag(AddableExerciseType.duration)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 220)

                Button("Add") {
                    addExercise()
                }
                .disabled(newExerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if exercises.isEmpty {
                Text("No custom exercises yet.")
                    .foregroundStyle(.secondary)
            } else {
                List {
                    ForEach(exercises, id: \.self) { name in
                        HStack {
                            Text(name)
                            Spacer()
                            Text(displayType(for: name))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule().fill(Color.secondary.opacity(0.12))
                                )
                                .accessibilityLabel("Type \(displayType(for: name))")
                        }
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
            }

            Spacer()
        }
        .padding()
        .onAppear(perform: load)
        .navigationTitle("Exercises List")
    }

    private func load() {
        exercises = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        if let dict = UserDefaults.standard.dictionary(forKey: typesKey) as? [String: String] {
            typesByName = dict
        } else {
            typesByName = [:]
        }
    }

    private func persist() {
        UserDefaults.standard.set(exercises, forKey: storageKey)
        UserDefaults.standard.set(typesByName, forKey: typesKey)
    }

    private func addExercise() {
        let trimmed = newExerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let name = trimmed

        if !exercises.contains(name) {
            exercises.append(name)
            // store type string
            typesByName[name] = typeString(from: selectedType)
            persist()
        } else {
            // If name exists, update its type to the latest selection
            typesByName[name] = typeString(from: selectedType)
            persist()
        }

        newExerciseName = ""
    }

    private func delete(at offsets: IndexSet) {
        let namesToRemove = offsets.map { exercises[$0] }
        exercises.remove(atOffsets: offsets)
        // Remove type entries for deleted names
        for n in namesToRemove {
            typesByName.removeValue(forKey: n)
        }
        persist()
    }

    // Helpers

    private func typeString(from type: AddableExerciseType) -> String {
        switch type {
        case .reps: return "reps"
        case .duration: return "duration"
        }
    }

    private func typeFromString(_ str: String?) -> AddableExerciseType {
        switch str?.lowercased() {
        case "duration": return .duration
        default: return .reps
        }
    }

    private func displayType(for name: String) -> String {
        let t = typeFromString(typesByName[name])
        switch t {
        case .reps: return "Reps"
        case .duration: return "Duration"
        }
    }
}

#Preview {
    NavigationView {
        ExercisesListSettingsView()
    }
}
