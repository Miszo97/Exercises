import Foundation

struct AddableExercise: Identifiable {
    let id = UUID()
    let name: String
    let type: AddableExerciseType
    let valueToAdd: Int
}

// Read names and types from UserDefaults
private func loadCustomExerciseNames() -> [String] {
    UserDefaults.standard.stringArray(forKey: "exercises_settings_list") ?? []
}

private func loadTypesMap() -> [String: String] {
    (UserDefaults.standard.dictionary(forKey: "exercises_settings_types") as? [String: String]) ?? [:]
}

private func typeFromString(_ str: String?) -> AddableExerciseType {
    switch str?.lowercased() {
    case "duration": return .duration
    default: return .reps
    }
}

// Helper to read the per-exercise "to add" value with a default based on type
private func valueToAdd(for name: String, type: AddableExerciseType) -> Int {
    let key = "exercises_settings_\(name)_to_add"
    let stored = UserDefaults.standard.integer(forKey: key)
    if stored != 0 {
        return stored
    }
    switch type {
    case .reps:     return 20
    case .duration: return 60
    }
}

// Build addable exercises from the user-managed list in settings
var addableExercises: [AddableExercise] {
    let names = loadCustomExerciseNames()
    let types = loadTypesMap()

    return names.map { name in
        let t = typeFromString(types[name])
        return AddableExercise(
            name: name,
            type: t,
            valueToAdd: valueToAdd(for: name, type: t)
        )
    }
}
