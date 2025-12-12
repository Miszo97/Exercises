import Combine
import SwiftUI

enum ExerciseTimer {
    case warm_up(Int)
    case brk(Int)
    case exercise(String, Int)

    var seconds: Int {
        switch self {
        case .warm_up(let value),
            .brk(let value),
            .exercise(_, let value):
            return value
        }
    }

    var name: String {
        switch self {
        case .warm_up:
            return "Warm up"
        case .brk:
            return "Break"
        case .exercise(let name, _):
            return name
        }
    }

}

struct HIITTimerView: View {
    let timers: [ExerciseTimer]
    @State var currentSeconds: String = "0"
    @State private var cancellables = Set<AnyCancellable>()
    @State private var previousTimerIndex: Int = 0

    @StateObject private var timer: HIITTimer

    let client = ExerciseClient()

    init(timers: [ExerciseTimer]) {
        self.timers = timers
        _timer = StateObject(wrappedValue: HIITTimer(timers: timers))

    }

    private var currentColor: Color {
        switch timer.currentTimer {
        case .warm_up:
            return .yellow
        case .brk:
            return .red
        case .exercise:
            return .green
        }
    }

    private var currentText: String {
        timer.currentTimer.name
    }

    private var currentTimer: ExerciseTimer {
        timers[timer.currentTimerIndex]
    }

    var body: some View {
        ZStack {
            currentColor
                .ignoresSafeArea()

            VStack {
                Text(String(timer.currentSeconds))
                    .font(
                        .system(size: 180, weight: .bold, design: .monospaced)
                    )
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text(currentText)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
            }
        }
        .onTapGesture {
            timer.toogleTimer()
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            
//            timer.$currentTimerIndex.sink { currentTimerIndex in
//
//
//            if case .exercise(let name, let duration) = timers[
//                previousTimerIndex
//            ] {
//                print(
//                    "Sending up: ",
//                    name, duration
//                )
//                Task {
//                    try await client.addDurationExercise(name: name, duration: duration)
//                }
//                
//            }
//                previousTimerIndex = currentTimerIndex
//        
//            }.store(in: &cancellables)
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onReceive(timer.$currentTimerIndex, perform: { currentTimerIndex in
            
            
            if case .exercise(let name, let duration) = timers[
                previousTimerIndex
            ] {
                print(
                    "Sending up: ",
                    name, duration
                )
                Task {
                    try await client.addDurationExercise(name: name, duration: duration)
                }
                
            }
                previousTimerIndex = currentTimerIndex
        
            })
    }
}

#Preview {
    let timers = [
        ExerciseTimer.warm_up(2),
        ExerciseTimer.exercise("left foot stabilization", 4),
        ExerciseTimer.brk(4),
        ExerciseTimer.exercise("right foot stabilization", 4),
        ExerciseTimer.brk(4),
        ExerciseTimer.exercise("left foot stabilization", 4),
        ExerciseTimer.brk(4),
        ExerciseTimer.exercise("right foot stabilization", 4),
    ]
    HIITTimerView(timers: timers)
}
