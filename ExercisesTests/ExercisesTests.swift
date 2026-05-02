import Testing
@testable import Exercises
import XCTest
import Combine

struct ExercisesTests {
    @Test
    func formatSecondsToMinutes(){
        #expect(Exercises.formatSecondsToMinutes(seconds:4) == "4 sec")
        #expect(Exercises.formatSecondsToMinutes(seconds:120) == "2 min")
        #expect(Exercises.formatSecondsToMinutes(seconds:124) == "2 min 4 sec")
    }


    @MainActor
    class HIITTimerTests: XCTestCase {
        var sut: HIITTimer!
        var cancellables: Set<AnyCancellable>!

        override func setUp() {
            super.setUp()
            cancellables = []

            let timers = [
                ExerciseTimer.warm_up(5),
                ExerciseTimer.exercise("test exercise", 10),
                ExerciseTimer.brk(3)
            ]
            sut = HIITTimer(timers: timers)
        }

        override func tearDown() {
            sut = nil
            cancellables = []
            super.tearDown()
        }

        // MARK: - Initialization Tests

        func testInitialization() {
            let timers = [
                ExerciseTimer.warm_up(5),
                ExerciseTimer.exercise("test exercise", 10)
            ]
            let timer = HIITTimer(timers: timers)

            print(timer.currentTimerIndex)

            XCTAssertEqual(timer.currentTimerIndex, 0)
            XCTAssertEqual(timer.currentSeconds, 0)
            XCTAssertEqual(timer.currentTimer.seconds, 5)
        }

        // MARK: - Toggle Timer Tests

        func testToggleTimerStartsTimer() {
            let expectation = XCTestExpectation(description: "Timer starts")

            sut.$currentSeconds
                .dropFirst()
                .first { $0 > 0 }
                .sink { _ in
                    expectation.fulfill()
                }
                .store(in: &cancellables)

            sut.toogleTimer()

            wait(for: [expectation], timeout: 1.0)
        }

        func testToggleTimerPausesTimer() {
            let expectation = XCTestExpectation(description: "Timer pauses")
            expectation.expectedFulfillmentCount = 2

            var firstValue: Int = 0

            sut.$currentSeconds
                .dropFirst()
                .sink { value in
                    if value > 0 && firstValue == 0 {
                        firstValue = value
                        expectation.fulfill()
                    }
                }
                .store(in: &cancellables)

            sut.toogleTimer()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let valueBefore = self.sut.currentSeconds
                self.sut.toogleTimer()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let valueAfter = self.sut.currentSeconds
                    XCTAssertEqual(valueBefore, valueAfter, "Timer should be paused")
                    expectation.fulfill()
                }
            }

            wait(for: [expectation], timeout: 2.0)
        }

        // MARK: - Timer Progression Tests

        func testTimerIncrementsSeconds() {
            let expectation = XCTestExpectation(description: "Seconds increment")

            var secondsProgressed = false

            sut.$currentSeconds
                .dropFirst()
                .sink { value in
                    if value >= 1 {
                        secondsProgressed = true
                        expectation.fulfill()
                    }
                }
                .store(in: &cancellables)

            sut.toogleTimer()

            wait(for: [expectation], timeout: 2.0)
            XCTAssertTrue(secondsProgressed)
        }

        // MARK: - Timer Index Advancement Tests

        func testTimerAdvancesToNextExerciseWhenComplete() {
            let shortTimers = [
                ExerciseTimer.warm_up(1),
                ExerciseTimer.exercise("test", 1),
                ExerciseTimer.brk(1)
            ]
            sut = HIITTimer(timers: shortTimers)

            let expectation = XCTestExpectation(description: "Timer advances to next exercise")

            sut.$currentTimerIndex
                .dropFirst()
                .sink { index in
                    if index > 0 {
                        expectation.fulfill()
                    }
                }
                .store(in: &cancellables)

            sut.toogleTimer()

            wait(for: [expectation], timeout: 3.0)
        }

        func testTimerLoopsBackToStartAtEnd() {
            let shortTimers = [
                ExerciseTimer.warm_up(1),
                ExerciseTimer.brk(1)
            ]
            sut = HIITTimer(timers: shortTimers)

            let expectation = XCTestExpectation(description: "Timer loops back to start")
            var loopedBack = false

            sut.$currentTimerIndex
                .dropFirst()
                .sink { index in
                    if index == 0 && loopedBack {
                        expectation.fulfill()
                    }
                    if index > 0 {
                        loopedBack = true
                    }
                }
                .store(in: &cancellables)

            sut.toogleTimer()

            wait(for: [expectation], timeout: 5.0)
        }

        // MARK: - Reset on Timer Switch Tests

        func testCurrentSecondsResetsWhenTimerChanges() {
            let shortTimers = [
                ExerciseTimer.warm_up(1),
                ExerciseTimer.exercise("test", 1)
            ]
            sut = HIITTimer(timers: shortTimers)

            let expectation = XCTestExpectation(description: "Seconds reset on timer change")
            var timerChanged = false

            sut.$currentTimerIndex
                .dropFirst()
                .sink { _ in
                    timerChanged = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        XCTAssertEqual(self.sut.currentSeconds, 0, "Seconds should reset to 0")
                        expectation.fulfill()
                    }
                }
                .store(in: &cancellables)

            sut.toogleTimer()

            wait(for: [expectation], timeout: 3.0)
        }

        // MARK: - Published Properties Tests

        func testCurrentTimerPublishes() {
            var receivedValues = [ExerciseTimer]()

            sut.$currentTimer
                .sink { timer in
                    receivedValues.append(timer)
                }
                .store(in: &cancellables)

            XCTAssertGreaterThan(receivedValues.count, 0)
            XCTAssertEqual(receivedValues.first?.seconds, 5)
        }

        func testCurrentSecondsPublishes() {
            var receivedValues = [Int]()

            sut.$currentSeconds
                .sink { seconds in
                    receivedValues.append(seconds)
                }
                .store(in: &cancellables)

            XCTAssertGreaterThan(receivedValues.count, 0)
        }
    }
}
