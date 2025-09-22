import Foundation


// This enum models the two possible row types:
enum ExerciseType: Identifiable {
    case reps(name: String, value: String)
    case duration(name: String, value: String)
    
    var id: String {
        switch self {
        case .reps(let name, _): return "reps-\(name)"
        case .duration(let name, _): return "duration-\(name)"
        }
    }
}

struct RowAPI: Decodable {
    var date: String
    var values: [String]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        date = try container.decode(String.self)
        values = try container.decode([String].self)
    }
}
