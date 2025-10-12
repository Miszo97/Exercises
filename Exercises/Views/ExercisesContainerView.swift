import SwiftUI

struct ExercisesContainerView: View {
    var rows: [ExerciseRow]

    var body: some View {
        if rows.isEmpty {
            VStack {
                Spacer()
                Text("No exercises found for today")
                    .foregroundColor(.secondary)
                    .padding(.top, 60)
                Spacer()
            }
        } else {
            List {
                ForEach(rows) { row in
                    switch row {
                    case .reps(let name, let value):
                        RepsExerciseRowView(name: name, value: value)
                    case .duration(let name, let value):
                        DurationExerciseRowView(name: name, value: value)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    ExercisesContainerView(rows: [
        .duration(name: "Plank", value: "60"),
        .reps(name: "Pushups", value: "20")
    ])
}
