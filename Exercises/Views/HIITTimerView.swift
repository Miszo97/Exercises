import SwiftUI
import Combine

enum ExerciseTimer {
    case warm_up(Int)
    case brk(Int)
    case exercise(String, Int)
}

@MainActor
class HIITTimer: ObservableObject {
    var isTimerRunning = false
    private var timeSpentOnPause: TimeInterval? = nil
    private var current_timer_index = 0

    private var timers: [ExerciseTimer]

    @Published var timerString = "0"
    @Published var currentName = ""

    private var timerCanalable: AnyCancellable = AnyCancellable {}

    private var startTime: Date? = Date()
    private var pauseTime: Date = Date()

    func toogleTimer() {
        if isTimerRunning {
            pauseTime = Date()
        } else {
            if timeSpentOnPause != nil {
                timeSpentOnPause! += Date().timeIntervalSince(pauseTime)
            } else {
                timeSpentOnPause = Date().timeIntervalSince(pauseTime)
            }
        }
        isTimerRunning.toggle()
    }

    init(timers: [ExerciseTimer]) {
        self.timers = timers
        self.timerCanalable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tickTimer()
            }
    }

    private func tickTimer() {
        if isTimerRunning {
            var value = 0
            currentName = ""
            let currentTimer = timers[current_timer_index]
            switch currentTimer {
            case .warm_up(let time):
                value = time
                currentName = "Warm up"
            case .brk(let time):
                value = time
                currentName = "Break"
            case .exercise(let name, let time):
                value = time
                currentName = name
            }
            
            if timerString == String(value) {
                timerString = "0"
                startTime = Date()
                pauseTime = Date()
                timeSpentOnPause = nil
                if current_timer_index == timers.count - 1 {
                    current_timer_index = 0
                    isTimerRunning.toggle()
                } else {
                    current_timer_index += 1
                }
                return
            }
            
                guard let start = self.startTime else {
                    self.startTime = Date()
                    return
                }
                var fullElapsedTime = Date().timeIntervalSince(start)
                if timeSpentOnPause != nil {
                    fullElapsedTime -= timeSpentOnPause!
                }
                timerString = String(Int(fullElapsedTime.rounded()))
                    }
    }
}

struct HIITTimerView: View {
    let timers: [ExerciseTimer]
    @State private var current_timer_index = 0

    // Own the ObservableObject so @Published updates propagate
    @StateObject private var timer: HIITTimer

    let client = ExerciseClient()

    init(timers: [ExerciseTimer]) {
        self.timers = timers
        _timer = StateObject(wrappedValue: HIITTimer(timers: timers))
    }

    private var currentColor: Color {
        let currentTimer = timers[current_timer_index]
        switch currentTimer {
        case .warm_up:
            return .yellow
        case .brk:
            return .red
        case .exercise:
            return .green
        }
    }

    var body: some View {
        ZStack {
            currentColor
                .ignoresSafeArea()

            VStack {
                Text(timer.timerString)
                    .font(.system(size: 180, weight: .bold, design: .monospaced))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text(timer.currentName)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
            }
        }
        .onTapGesture {
            timer.toogleTimer()
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}

#Preview {
    let timers = [
        ExerciseTimer.warm_up(10),
        ExerciseTimer.exercise("left foot stabilization", 30),
        ExerciseTimer.brk(15),
        ExerciseTimer.exercise("right foot stabilization", 30),
        ExerciseTimer.brk(15),
        ExerciseTimer.exercise("left foot stabilization", 30),
        ExerciseTimer.brk(15),
        ExerciseTimer.exercise("right foot stabilization", 30)
    ]
    HIITTimerView(timers: timers)
}
