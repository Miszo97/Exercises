import SwiftUI

struct AddExerciseListView: View {
    let addableExercises: [AddableExercise]
    let reload: () async -> Void
    private let client = ExerciseClient()
    @Binding var rows: [String: Int]

    private func statItem(for exercise: AddableExercise) -> StatItem {
        StatItem(
            title: exercise.name.capitalized,
            value: "",
            subtitle: nil,
            rawName: exercise.name
        )
    }

    var body: some View {
        VStack {
            ForEach(addableExercises) { exercise in
                NavigationLink {
                    StatisticsDetailView(item: statItem(for: exercise))
                } label: {
                    switch exercise.type {
                    case .reps:
                        VStack {
                            AddRepsExerciseRowView(
                                name: exercise.name,
                                initialValue: exercise.valueToAdd,
                                reload: reload
                            )
                            HStack {
                                if let value = rows[exercise.name] {
                                    Text(String(value)).padding(.horizontal)
                                }
                                Spacer()
                            }
                        }
                    case .duration:
                        VStack {
                            AddDurationExerciseRowView(
                                name: exercise.name,
                                initialValue: exercise.valueToAdd,
                                reload: reload
                            )
                            HStack {
                                if let value = rows[exercise.name] {
                                    Text(formatSecondsToMinutes(seconds: value))
                                        .padding(.horizontal)
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .buttonStyle(.plain)  // keep row’s original look
            }
        }
        .padding(.bottom, 150)
        .padding(.top, 20)
    }
}

#Preview {
    NavigationStack {
        AddExerciseListView(
            addableExercises: [
                .init(name: "push ups", type: .reps, valueToAdd: 20),
                .init(name: "plank", type: .duration, valueToAdd: 60),
            ],
            reload: {},
            rows: .constant(["push ups": 15, "plank": 69])
        )
    }
}
