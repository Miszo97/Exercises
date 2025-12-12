import Combine
import Foundation
import Playgrounds
import SwiftUI

@MainActor
class HIITTimer: ObservableObject {
    @Published var currentTimer: ExerciseTimer
    @Published var currentTimerIndex: Int = 0
    @Published var currentSeconds: Int
    
    private var isTimerRunning = false
    private var timeSpentOnPause: TimeInterval? = nil
    private var timerCanalable: AnyCancellable = AnyCancellable {}
    private var startTime: Date? = Date()
    private var pauseTime: Date = Date()
    private var timers: [ExerciseTimer]

    
    init(timers: [ExerciseTimer]) {
        self.timers = timers
        currentTimer = timers[0]
        currentSeconds = 0
    }

    func toogleTimer() {
        if isTimerRunning {
            pauseTime = Date()
            self.timerCanalable.cancel()
        } else {
            if timeSpentOnPause != nil {
                timeSpentOnPause! += Date().timeIntervalSince(pauseTime)
            } else {
                timeSpentOnPause = Date().timeIntervalSince(pauseTime)
            }
            self.timerCanalable = Timer.publish(every: 0.1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] date in
                    self?.tickTimer(date: date)
                }
        }
        isTimerRunning.toggle()
    }



    private func tickTimer(date: Date) {
        if isTimerRunning {
            if currentSeconds >= currentTimer.seconds {
                currentSeconds = 0
                startTime = Date()
                pauseTime = Date()
                timeSpentOnPause = nil
                if currentTimerIndex == timers.count - 1 {
                    currentTimerIndex = 0
                    isTimerRunning.toggle()
                } else {
                    currentTimerIndex += 1
                }
                currentTimer = timers[currentTimerIndex]
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
            currentSeconds = Int(fullElapsedTime.rounded())
        }
    }
}

