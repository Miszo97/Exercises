import SwiftUI

@main
struct ExercisesApp: App {
    init() {
        // Prevent auto-lock for the entire lifetime of the app
        UIApplication.shared.isIdleTimerDisabled = true
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
