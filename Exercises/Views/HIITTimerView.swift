import SwiftUI

enum ExerciseTimer{
    case warm_up(Int)
    case brk(Int)
    case exercise(String, Int)
}
struct HIITTimerView: View {
    @State var isTimerRunning = false
    @State private var startTime: Date? = Date()
    @State private var pauseTime: Date = Date()
    @State private var timerString = "0"
    @State private var timeSpentOnPause: TimeInterval? = nil
    let timers: [ExerciseTimer]
    @State private var current_timer_index = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let client = ExerciseClient()
    @State var currentName = ""
    
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
            
            VStack{
                Text(self.timerString)
                    .font(.system(size: 180, weight: .bold, design: .monospaced))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                Text(self.currentName).font(.system(size: 40, weight: .bold, design: .monospaced))
            }
        }
        .onReceive(timer) { _ in
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
            
            if (timerString == String(value)) {
                if (currentName != "Warm up" && currentName != "Break") {
                    let nameToSend = currentName
                    let durationToSend = value
                    Task {
                        do {
                            try await client.addDurationExercise(name: nameToSend, duration: durationToSend)
                        } catch {
                            // Log the error; keep ticking
                            print("Failed to add duration exercise: \(error)")
                        }
                    }
                }
                timerString = "0"
                startTime =  Date()
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
            if self.isTimerRunning {
                guard let start = self.startTime else {
                    self.startTime = Date()
                    return
                }
                var fullElapsedTime = Date().timeIntervalSince(start)
                if timeSpentOnPause != nil{
                    fullElapsedTime = fullElapsedTime - timeSpentOnPause!
                }
                timerString = String(Int(fullElapsedTime.rounded()))
            }
        }
        .onTapGesture {
            if isTimerRunning {
                pauseTime = Date()
            } else{
                if timeSpentOnPause != nil{
                    timeSpentOnPause! += Date().timeIntervalSince(pauseTime)
                }
                else {
                    timeSpentOnPause = Date().timeIntervalSince(pauseTime)
                }
            }
            isTimerRunning.toggle()
        }
        .onAppear {
            // Keep the device awake while this view is visible
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            // Restore default behavior when leaving the view
            UIApplication.shared.isIdleTimerDisabled = false
        }
        
    }
}


#Preview {
    let timers = [ExerciseTimer.warm_up(10), ExerciseTimer.exercise("left foot stabilization", 30), ExerciseTimer.brk(15), ExerciseTimer.exercise("right foot stabilization", 30),
                  ExerciseTimer.brk(15), ExerciseTimer.exercise("left foot stabilization", 30),
                  ExerciseTimer.brk(15), ExerciseTimer.exercise("right foot stabilization", 30)]
    HIITTimerView(timers: timers)
}
