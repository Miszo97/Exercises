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

            ExercisesListSettingsView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle")
                }

            HIITView()
                .tabItem {
                    Label(
                        "HIIT",
                        systemImage: "figure.highintensity.intervaltraining"
                    )
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
            
            SystmeSoundEffectDemo()
        }
    }
}

#Preview {
    ContentView()
}
