import SwiftUI

struct HIITTraining: Hashable{
    let name: String
    let timers: [ExerciseTimer]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: HIITTraining, rhs: HIITTraining) -> Bool {
        return lhs.name == rhs.name
    }
}



struct HIITView: View {
    let trainings = [
        HIITTraining(
            name: "Foot stabilization",
            timers: [
                ExerciseTimer.warm_up(10),
                ExerciseTimer.exercise("left foot stabilization", 30),
                ExerciseTimer.brk(10),
                ExerciseTimer.exercise("right foot stabilization", 30),
                ExerciseTimer.brk(10),
                ExerciseTimer.exercise("right foot stabilization", 30)
            ]
        ),
        HIITTraining(
            name: "Plank",
            timers: [
                ExerciseTimer.warm_up(10),
                ExerciseTimer.exercise("plank", 60),
                ExerciseTimer.brk(10),
                ExerciseTimer.exercise("plank left side", 60),
                ExerciseTimer.brk(10),
                ExerciseTimer.exercise("plank right side", 60)
            ]
        ),
        HIITTraining(
            name: "Foot stabilization foam pad closed eyes",
            timers: [
                ExerciseTimer.warm_up(5),
                ExerciseTimer.exercise("left foot stabilization foam pad closed eyes", 30),
                ExerciseTimer.brk(5),
                ExerciseTimer.exercise("right foot stabilization foam pad closed eyes", 30),
                ExerciseTimer.brk(5),
                ExerciseTimer.exercise("left foot stabilization foam pad closed eyes", 30),
                ExerciseTimer.brk(5),
                ExerciseTimer.exercise("right foot stabilization foam pad closed eyes", 30),
            ]
        ),
        HIITTraining(
            name: "Ankle stabilization",
            timers: [
                ExerciseTimer.warm_up(5),
                ExerciseTimer.exercise("left ankle stabilization", 30),
                ExerciseTimer.brk(5),
                ExerciseTimer.exercise("right ankle stabilization", 30),
                ExerciseTimer.brk(5),
                ExerciseTimer.exercise("left ankle stabilization", 30),
                ExerciseTimer.brk(5),
                ExerciseTimer.exercise("right ankle stabilization", 30),
            ]
        )
        
    ]
                                  
    var body: some View {
        NavigationStack{
            List(trainings, id: \.self) { training in
                NavigationLink(training.name, value: training)
            }
            .navigationDestination(for: HIITTraining.self) { training in
                HIITTimerView(timers: training.timers)
            }
        }
    }
}

#Preview {
    HIITView()
}
