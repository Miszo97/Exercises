//
//  Statistics.swift
//  Exercises
//
//  Created by Artur Spek on 30/10/2025.
//

import SwiftUI
import Playgrounds

struct StatItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let value: String
    let subtitle: String?
    // Raw API name to use for requests (avoid capitalization/format differences)
    let rawName: String
}

struct StatisticsDetailView: View {
    let item: StatItem

    @State private var entries: [Exercise] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let client = ExerciseClient()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
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
            }
            .padding()

            // Content
            Group {
                if isLoading && entries.isEmpty && errorMessage == nil {
                    VStack(spacing: 12) {
                        ProgressView("Loading…")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding()
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Text("Failed to load entries")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button("Retry") {
                            Task { await loadEntries() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding()
                } else if entries.isEmpty {
                    VStack(spacing: 12) {
                        Text("No entries found")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding()
                } else {
                    List {
                        ForEach(entries.indices, id: \.self) { idx in
                            let e = entries[idx]
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(e.date ?? "")
                                        .font(.headline)
                                    Text(e.name)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if let reps = e.reps {
                                    Text("\(reps)")
                                        .monospacedDigit()
                                        .font(.title3)
                                        .accessibilityLabel("\(reps) reps")
                                } else if let duration = e.duration {
                                    Text("\(duration)s")
                                        .monospacedDigit()
                                        .font(.title3)
                                        .accessibilityLabel("\(duration) seconds")
                                } else {
                                    Text("-")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .task {
                await loadEntries()
            }
            .refreshable {
                await loadEntries()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func loadEntries() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        do {
            let data = try await client.fetchExerciseEntries(for: item.rawName)
            await MainActor.run {
                self.entries = data
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

struct Statistics: View {
    @State private var items: [StatItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let client = ExerciseClient()


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
    
//    UserDefaults.standard.object(forKey: "exercises_settings_types") as! NSDictionary).filter({(key: Any, val: String) -> Bool in val=="reps"}


    private func loadStats() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        do {
            let reps_names = try (UserDefaults.standard.object(forKey: "exercises_settings_types") as! [String:String]).filter({(e) throws -> Bool in e.value=="reps"}).compactMap {e in e.key}
            let perRepsItems = try await perExerciseItems(
                names: reps_names,
                fetch: { try await client.fetchTotalReps(for: $0) },
                valueText: { NumberFormatter.localizedString(from: NSNumber(value: $0), number: .decimal) },
                subtitleText: { _ in "Total number" }
            )

            let duration_names = try (UserDefaults.standard.object(forKey: "exercises_settings_types") as! [String:String]).filter({(e) throws -> Bool in e.value=="duration"}).compactMap {e in e.key}
            let perDurationItems = try await perExerciseItems(
                names: duration_names,
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
                subtitle: subtitleText(value),
                rawName: name
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
