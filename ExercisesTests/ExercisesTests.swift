import Testing
@testable import Exercises

func add_to_numbers(_ a: Int, _ b: Int) -> Int {
    return a + b
}

struct ExercisesTests {

    @Test func example() async throws {
        let results = try await fetch_today_exercises()
        #expect(results.count > 0)
        #expect(results[0].reps == 100)
    }
    
    @Test("Sum results", arguments: [
        [1,2,3],
        [1,5,6],
        [2,2,4],
    ])
    func mentionedContinents(numbers: [Int]) async throws {
        let result = add_to_numbers(numbers[0], numbers[1])
        #expect(result == numbers[2])
    }

}

