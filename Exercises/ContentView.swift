import SwiftUI

let api_url = "http://kevin224.mikrus.xyz:20224/table"

enum AddableExerciseType {
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
