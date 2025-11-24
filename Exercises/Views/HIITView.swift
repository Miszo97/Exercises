//
//  HIITView.swift
//  Exercises
//
//  Created by Artur Spek on 21/11/2025.
//

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
    let trainings = [HIITTraining(name: "Foot stabilization",
                                timers: [ExerciseTimer.warm_up(10), ExerciseTimer.exercise("left foot stabilization", 30), ExerciseTimer.brk(10), ExerciseTimer.exercise("right foot stabilization", 30), ExerciseTimer.brk(10),
                                         ExerciseTimer.exercise("left foot stabilization", 30),ExerciseTimer.brk(10),
                                         ExerciseTimer.exercise("right foot stabilization", 30)])]
                                  
    
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
