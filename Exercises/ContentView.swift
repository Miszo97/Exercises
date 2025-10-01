import SwiftUI

let api_url = "https://exercises-581797442525.europe-central2.run.app/today"

enum AddableExerciseType {
    case reps
    case duration
}

struct AddableExercise: Identifiable {
    let id = UUID()
    let name: String
    let type: AddableExerciseType
    let valueToAdd: Int
}

struct ContentView: View {
    @State private var rows: [ExerciseType] = []
    
    private let addableExercises: [AddableExercise] = [
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

    var body: some View {
        VStack {
            Title()
            
            Button {
                Task {
                    await loadExercises()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
                    .accessibilityLabel("Get exercises")
            }

            AddExerciseList(addableExercises: addableExercises)
            
            Spacer()
            ExercisesContainer(rows: rows)
        }
        .padding()
        .task {
            await loadExercises()
        }
        
    }

    func loadExercises() async {
        do {
            let exercises = try await fetch_today_exercises()
            let loadedRows: [ExerciseType] = exercises.compactMap { exercise in
                switch exercise.type.lowercased() {
                case "reps":
                    let value = exercise.reps.map { String($0) } ?? "—"
                    return .reps(name: exercise.name, value: value)
                case "duration":
                    let value = exercise.duration.map { String($0) } ?? "—"
                    return .duration(name: exercise.name, value: value)
                default:
                    return nil // Ignore unknown types
                }
            }
            await MainActor.run {
                self.rows = loadedRows
            }
        } catch {
            print("Failed to load exercises:", error)
            // Optionally display error to user
        }
    }
}

#Preview {
    ContentView()
}

struct Title: View {
    let api_url = "https://exercises-581797442525.europe-central2.run.app/table"

    var body: some View {
        HStack {
            Header(content: "Exercises")
            Link(destination: URL(string: api_url)!) {
                Image(systemName: "link") // SF Symbol for a link
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.blue)
                    .padding()
            }
        }
    }
}
