import SwiftUI

struct MainView: View {
    @State private var rows: [String: Int] = [:]
    @State private var isLoading: Bool = false
    private let availableExercises: [AddableExercise]
    private let client = ExerciseClient()
    private let shouldLoadOnAppear: Bool

    init(initialRows: [String: Int] = [:], shouldLoadOnAppear: Bool = true, initialAddableExercises: [AddableExercise]? = nil) {
        _rows = State(initialValue: initialRows)
        self.shouldLoadOnAppear = shouldLoadOnAppear
        self.availableExercises = initialAddableExercises ?? addableExercises
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    TitleView().padding(10)

                    AddExerciseListView(
                        addableExercises: availableExercises,
                        reload: {
                            await loadExercises()
                        },
                        rows: $rows
                    )

                    Spacer()
                }
                .padding()
            }
            .task {
                if shouldLoadOnAppear {
                    await loadExercises()
                }
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
        }
    }
}

#Preview {
    MainView(
        initialRows: [
            "push ups": 40,
            "plank": 120,
            "squats": 60
        ],
        shouldLoadOnAppear: false,
        initialAddableExercises: [
            AddableExercise(name: "push ups", type: .reps, valueToAdd: 20),
            AddableExercise(name: "plank", type: .duration, valueToAdd: 60),
            AddableExercise(name: "squats", type: .reps, valueToAdd: 30),
        ]
    )
}