//
//  MainView.swift
//  Exercises
//
//  Created by Artur Spek on 13/10/2025.
//


import SwiftUI

struct MainView: View {
    @State private var rows: [ExerciseRow] = []
    @State private var isLoading: Bool = false
    private let client = ExerciseClient()
    
    var body: some View {
        VStack {
            TitleView().padding(10)
            
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
            let exercises = try await client.fetchTodayExercises()
            let loadedRows: [ExerciseRow] = exercises.compactMap { exercise in
                // Derive row type from which value is present.
                if let reps = exercise.reps {
                    return .reps(name: exercise.name, value: String(reps))
                } else if let duration = exercise.duration {
                    return .duration(name: exercise.name, value: String(duration))
                } else {
                    return nil
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
    MainView()
}
