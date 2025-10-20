//
//  AddExerciseList.swift
//  Exercises
//
//  Created by Artur Spek on 28/09/2025.
//

import SwiftUI

struct AddExerciseListView: View {
    let addableExercises: [AddableExercise]
    private let client = ExerciseClient()

    // Helper to fetch the latest timestamp for an exercise name
    private func latestLogDate(for name: String) -> Date? {
        let key = "exercises_logs_\(name)"
        guard let logs = UserDefaults.standard.stringArray(forKey: key),
              let latest = logs.last else {
            return nil
        }
        return ISO8601DateFormatter().date(from: latest)
    }

    // Compute a sorted list by latest log date (most recent first).
    // Exercises without logs will be placed at the end.
    private var sortedExercises: [AddableExercise] {
        addableExercises.sorted { lhs, rhs in
            let lDate = latestLogDate(for: lhs.name)
            let rDate = latestLogDate(for: rhs.name)
            switch (lDate, rDate) {
            case let (l?, r?):
                return l > r // most recent first
            case (nil, .some):
                return false // rhs has a date, lhs goes after
            case (.some, nil):
                return true  // lhs has a date, rhs goes after
            case (nil, nil):
                // stable by name to keep deterministic order if no logs
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
        }
    }

    var body: some View {
        VStack {
            ForEach(sortedExercises) { exercise in
                switch exercise.type {
                case .reps:
                    AddRepsExerciseRowView(
                        name: exercise.name,
                        initialValue: exercise.valueToAdd
                    )
                case .duration:
                    AddDurationExerciseRowView(
                        name: exercise.name,
                        initialValue: exercise.valueToAdd
                    )
                }
            }
        }
        .padding(.bottom, 150)
        .padding(.top, 20)
        // Recompute when view appears or when app returns to foreground,
        // since UserDefaults may have changed outside this view’s lifecycle.
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Trigger a body refresh; no-op needed because sortedExercises is computed from UserDefaults on each render.
        }
    }
}

#Preview {
    AddExerciseListView(
        addableExercises: [
            .init(name: "push ups", type: .reps, valueToAdd: 20),
            .init(name: "plank", type: .duration, valueToAdd: 60)
        ]
    )
}
