import SwiftUI

struct MainView: View {
    @State private var rows: [String: Int] = [:]
    @State private var isLoading: Bool = false
    private let client = ExerciseClient()

    var body: some View {
        NavigationStack {
            VStack {
                TitleView().padding(10)
                
                AddExerciseListView(
                    addableExercises: addableExercises,
                    reload: {
                        await loadExercises()
                    },
                    rows: $rows
                )
                
                Spacer()
            }
            .padding()
            .task {
                await loadExercises()
            }
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
