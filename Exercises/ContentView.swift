import SwiftUI

let api_url = "https://exercises-581797442525.europe-central2.run.app/today"

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
