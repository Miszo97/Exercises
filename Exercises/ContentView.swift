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
}

struct ContentView: View {
    @State private var rows: [ExerciseType] = []
    
    // All available "add" exercises are defined here
    private let addableExercises: [AddableExercise] = [
        .init(name: "push ups", type: .reps),
        .init(name: "band exterior top", type: .reps),
        .init(name: "plank", type: .duration),
        .init(name: "plank both sides", type: .duration),
    ]

    var body: some View {
        VStack {
            Title()
            
            Button ("get exercises") {
                Task {
                    await loadExercises()
                }
            }

            VStack {
                ForEach(addableExercises) { exercise in
                    switch exercise.type {
                    case .reps:
                        AddRepsExerciseRow(name: exercise.name, onAdd: loadExercises)
                    case .duration:
                        AddDurationExerciseRow(name: exercise.name, onAdd: loadExercises)
                    }
                }
                Spacer()
                ExercisesContainer(rows: rows)
            }.padding(.bottom, 150).padding(.top, 20)
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
                self.rows = loadedRows.isEmpty
                    ? [.duration(name: "No exercises found for today", value: "")]
                    : loadedRows
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
