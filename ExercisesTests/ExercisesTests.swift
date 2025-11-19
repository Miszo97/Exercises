import Testing
@testable import Exercises


struct ExercisesTests {
    @Test
    func formatSecondsToMinutes(){
        #expect(Exercises.formatSecondsToMinutes(seconds:4) == "4 sec")
        #expect(Exercises.formatSecondsToMinutes(seconds:120) == "2 min")
        #expect(Exercises.formatSecondsToMinutes(seconds:124) == "2 min 4 sec")
    }
}
