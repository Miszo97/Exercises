import SwiftUI

struct ExercisesContainer: View {
    var rows: [ExerciseType]

    var body: some View {
        ForEach(rows) { row in
            switch row {
            case .reps(let name, let value):
                RepsExerciseRow(name: name, value: value)
            case .duration(let name, let value):
                DurationExerciseRow(name: name, value: value)
            }
        }
    }
}

#Preview {
    ExercisesContainer(rows: [
        .duration(name: "Plank", value: "60"),
        .reps(name: "Pushups", value: "20")
    ])
}
