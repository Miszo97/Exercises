import SwiftUI

enum AddableExerciseType: Equatable {
    case reps
    case duration
}

struct ContentView: View {
    let timers = [ExerciseTimer.warm_up(10), ExerciseTimer.exercise("plank", 60), ExerciseTimer.brk(5), ExerciseTimer.exercise("plank both sides", 60), ExerciseTimer.brk(5), ExerciseTimer.exercise("plank both sides", 60)]

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
            
            HIITView()
                .tabItem {
                    Label("HIIT", systemImage: "figure.highintensity.intervaltraining")
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

