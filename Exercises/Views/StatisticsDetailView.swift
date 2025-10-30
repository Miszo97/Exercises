//
//  Statistics.swift
//  Exercises
//
//  Created by Artur Spek on 30/10/2025.
//

import SwiftUI

struct StatItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let value: String
    let subtitle: String?
}

struct StatisticsDetailView: View {
    let item: StatItem

    var body: some View {
        VStack(spacing: 16) {
            Text(item.title)
                .font(.largeTitle)
                .bold()

            Text(item.value)
                .font(.system(size: 48, weight: .semibold, design: .rounded))
                .monospacedDigit()

            if let subtitle = item.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct Statistics: View {
    @State private var items: [StatItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let client = ExerciseClient()

    // Hardcoded lists of exercises to show as individual rows
    private let repsExerciseNames: [String] = [
        "push ups",
        "band exterior top"
        // add more reps-based exercises here
    ]

    private let durationExerciseNames: [String] = [
        "plank",
        "plank both sides"
        // add more duration-based exercises here
    ]

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && items.isEmpty {
                    ProgressView("Loading statistics…")
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Text("Failed to load statistics")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button("Retry") {
                            Task { await loadStats() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List(items) { item in
                        NavigationLink(value: item) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.headline)
                                    if let subtitle = item.subtitle {
                                        Text(subtitle)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Text(item.value)
                                    .font(.title3)
                                    .monospacedDigit()
                                    .foregroundStyle(.primary)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .navigationTitle("Statistics")
            .navigationDestination(for: StatItem.self) { item in
                StatisticsDetailView(item: item)
            }
            .task {
                await loadStats()
            }
            .refreshable {
                await loadStats()
            }
        }
    }

    private func loadStats() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        do {
            // Build one StatItem per exercise (reps and duration), concurrently.
            let perRepsItems = try await perExerciseItems(
                names: repsExerciseNames,
                fetch: { try await client.fetchTotalReps(for: $0) },
                valueText: { NumberFormatter.localizedString(from: NSNumber(value: $0), number: .decimal) },
                subtitleText: { _ in "Total number" }
            )

            let perDurationItems = try await perExerciseItems(
                names: durationExerciseNames,
                fetch: { try await client.fetchTotalDuration(for: $0) },
                valueText: { formatSeconds($0) },
                subtitleText: { _ in "Total duration" }
            )

            let newItems = perRepsItems + perDurationItems

            await MainActor.run {
                self.items = newItems
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // Helper to fetch and build items for a list of names
    private func perExerciseItems(
        names: [String],
        fetch: @escaping (String) async throws -> Int,
        valueText: @escaping (Int) -> String,
        subtitleText: @escaping (Int) -> String
    ) async throws -> [StatItem] {
        if names.isEmpty { return [] }

        // Fetch in parallel, then keep original order of names in the output list
        var results: [(name: String, value: Int)] = []
        results.reserveCapacity(names.count)

        try await withThrowingTaskGroup(of: (String, Int).self) { group in
            for name in names {
                group.addTask {
                    let v = try await fetch(name)
                    return (name, v)
                }
            }
            for try await pair in group {
                results.append(pair)
            }
        }

        // Sort by the original names order
        let indexByName = Dictionary(uniqueKeysWithValues: names.enumerated().map { ($1, $0) })
        results.sort { (lhs, rhs) in
            (indexByName[lhs.name] ?? 0) < (indexByName[rhs.name] ?? 0)
        }

        return results.map { (name, value) in
            StatItem(
                title: "\(name.capitalized)",
                value: valueText(value),
                subtitle: subtitleText(value)
            )
        }
    }

    private func formatSeconds(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60

        var parts: [String] = []
        if h > 0 { parts.append("\(h)h") }
        if m > 0 || h > 0 { parts.append("\(m)m") }
        parts.append("\(s)s")
        return parts.joined(separator: " ")
    }
}

#Preview {
    Statistics()
}
