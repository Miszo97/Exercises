//
//  MainView.swift
//  Exercises
//
//  Created by Artur Spek on 13/10/2025.
//


import SwiftUI

struct MainView: View {
    @State private var rows: Dictionary<String, Int> = [:]
    @State private var isLoading: Bool = false
    private let client = ExerciseClient()
    
    var body: some View {
        VStack {
            TitleView().padding(10)
            
            AddExerciseListView(addableExercises: addableExercises, reload: {
                await loadExercises()
            },
                                rows: $rows)
            
            Spacer()
        }
        .padding()
        .task {
            await loadExercises()
        }
        
    }
    
    func loadExercises() async {
        do {
            let loadedRows = try await client.fetchTodayExercises()
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
