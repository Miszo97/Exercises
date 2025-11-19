import SwiftUI

enum AddableExerciseType: Equatable {
    case reps
    case duration
}

struct ContentView: View {

    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Label("Exercises", systemImage: "figure.walk")
                }

            Statistics()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar")
                }
            
            ExercisesListSettingsView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
}

