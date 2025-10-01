//
//  AddExerciseList.swift
//  Exercises
//
//  Created by Artur Spek on 28/09/2025.
//

import SwiftUI

struct AddExerciseList: View {
    let addableExercises: [AddableExercise]

    var body: some View {
        VStack {
            ForEach(addableExercises) { exercise in
                switch exercise.type {
                case .reps:
                    AddExerciseRow(
                        name: exercise.name,
                        initialValue: exercise.valueToAdd,
                        performAdd: { value in
                            try await addRepsExercise(name: exercise.name, reps: value)
                        }
                    )
                case .duration:
                    AddExerciseRow(
                        name: exercise.name,
                        initialValue: exercise.valueToAdd,
                        performAdd: { value in
                            try await addDurationExercise(name: exercise.name, duration: value, unit: "seconds")
                        }
                    )
                }
            }
        }
        .padding(.bottom, 150)
        .padding(.top, 20)
    }
}

#Preview {
    AddExerciseList(
        addableExercises: [
            .init(name: "push ups", type: .reps, valueToAdd: 20),
            .init(name: "plank", type: .duration, valueToAdd: 60)
        ]
    )
}
