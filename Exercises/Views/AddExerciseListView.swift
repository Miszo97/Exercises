//
//  AddExerciseList.swift
//  Exercises
//
//  Created by Artur Spek on 28/09/2025.
//

import SwiftUI

struct AddExerciseListView: View {
    let addableExercises: [AddableExercise]
    let reload: () async -> Void
    private let client = ExerciseClient()
    @Binding var rows: Dictionary<String, Int>

    // Helper to fetch the latest timestamp for an exercise name
    private func latestLogDate(for name: String) -> Date? {
        let key = "exercises_logs_\(name)"
        guard let logs = UserDefaults.standard.stringArray(forKey: key),
              let latest = logs.last else {
            return nil
        }
        return ISO8601DateFormatter().date(from: latest)
    }

    // Compute a sorted list by latest log date (oldest first).
    // Exercises without logs will be placed at the beginning.
    private var sortedExercises: [AddableExercise] {
        addableExercises.sorted { lhs, rhs in
            let lDate = latestLogDate(for: lhs.name)
            let rDate = latestLogDate(for: rhs.name)
            switch (lDate, rDate) {
            case let (l?, r?):
                return l < r // oldest first
            case (nil, .some):
                return true  // lhs has no date, comes before rhs
            case (.some, nil):
                return false // rhs has no date, comes before lhs
            case (nil, nil):
                // reverse name order to fully reverse previous behavior
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedDescending
            }
        }
    }

    var body: some View {
        VStack {
            ForEach(sortedExercises) { exercise in
                switch exercise.type {
                case .reps:
                    VStack{
                        AddRepsExerciseRowView(
                            name: exercise.name,
                            initialValue: exercise.valueToAdd,
                            reload: reload
                        )
                        HStack{
                        if let value = rows[exercise.name] {
                            Text(String(value)).padding(.horizontal)
                        }
                            Spacer()
                        }
                    }
                case .duration:
                    VStack{
                        AddDurationExerciseRowView(
                            name: exercise.name,
                            initialValue: exercise.valueToAdd,
                            reload: reload
                        )
                        HStack{
                        if let value = rows[exercise.name] {
                            Text(String(value)).padding(.horizontal)
                        }
                            Spacer()
                        }
                    }
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
        ],
        reload: {},
        rows: .constant(["push ups": 15, "plank": 40])
    )
}
