import SwiftUI

let api_url = "https://exercises-581797442525.europe-central2.run.app/today"

enum AddableExerciseType {
    case reps
    case duration
}


struct ContentView: View {
    @State private var rows: [ExerciseType] = []

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

            AddExerciseListView(addableExercises: addableExercises)
            
            Spacer()
            ExercisesContainerView(rows: rows)
        }
        .padding()
        .task {
            await loadExercises()
        }
        
    }

    func loadExercises() async {
        do {
            let exercises = try await fetchTodayExercises()
            let loadedRows: [ExerciseRow] = exercises.compactMap { exercise in
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
            HeaderView(content: "Exercises")
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
