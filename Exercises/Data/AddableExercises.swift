import Foundation

struct AddableExercise: Identifiable {
    let id = UUID()
    let name: String
    let type: AddableExerciseType
    let valueToAdd: Int
}

let addableExercises: [AddableExercise] = [
    .init(
        name: "push ups",
        type: .reps,
        valueToAdd: UserDefaults.standard.integer(forKey: "exercises_settings_push ups_to_add") == 0 ? 20 : UserDefaults.standard.integer(forKey: "exercises_settings_push ups_to_add")
    ),
    .init(
        name: "band exterior top",
        type: .reps,
        valueToAdd: UserDefaults.standard.integer(forKey: "exercises_settings_band exterior top_to_add") == 0 ? 20 : UserDefaults.standard.integer(forKey: "exercises_settings_band exterior top_to_add")
    ),
    .init(
        name: "plank",
        type: .duration,
        valueToAdd: UserDefaults.standard.integer(forKey: "exercises_settings_plank_to_add") == 0 ? 60 : UserDefaults.standard.integer(forKey: "exercises_settings_plank_to_add")
    ),
    .init(
        name: "plank both sides",
        type: .duration,
        valueToAdd: UserDefaults.standard.integer(forKey: "exercises_settings_plank both sides_to_add") == 0 ? 60 : UserDefaults.standard.integer(forKey: "exercises_settings_plank both sides_to_add")
    )
]
