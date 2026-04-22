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
            AddableExercise(name: "jumping jacks", type: .reps, valueToAdd: 40),
            AddableExercise(name: "burpees", type: .reps, valueToAdd: 10),
            AddableExercise(name: "lunges", type: .reps, valueToAdd: 20),
            AddableExercise(name: "bicycle crunches", type: .reps, valueToAdd: 15),
            AddableExercise(name: "mountain climbers", type: .reps, valueToAdd: 50),
            AddableExercise(name: "sit ups", type: .reps, valueToAdd: 25),
            AddableExercise(name: "high knees", type: .duration, valueToAdd: 30),
            AddableExercise(name: "leg raises", type: .reps, valueToAdd: 20),
            AddableExercise(name: "tricep dips", type: .reps, valueToAdd: 15),
            AddableExercise(name: "calf raises", type: .reps, valueToAdd: 30),
            AddableExercise(name: "wall sit", type: .duration, valueToAdd: 45),
            AddableExercise(name: "heel touches", type: .reps, valueToAdd: 20),
            AddableExercise(name: "superman", type: .duration, valueToAdd: 60),
            AddableExercise(name: "flutter kicks", type: .duration, valueToAdd: 45),
            AddableExercise(name: "side lunges", type: .reps, valueToAdd: 20),
            AddableExercise(name: "shoulder taps", type: .reps, valueToAdd: 30),
            AddableExercise(name: "skaters", type: .reps, valueToAdd: 30),
            AddableExercise(name: "reverse lunges", type: .reps, valueToAdd: 20),
            AddableExercise(name: "butt kicks", type: .duration, valueToAdd: 30),
            AddableExercise(name: "side planks", type: .duration, valueToAdd: 30)
        ]
    )
}