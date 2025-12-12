import Charts
import Playgrounds
import SwiftUI

struct StatItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let value: String
    let subtitle: String?
    let rawName: String
}

struct ChartData: Identifiable, Hashable {
    let id = UUID()
    let day: Date
    let value: Int
}

struct StatisticsDetailView: View {
    let item: StatItem

    @State private var entries: [Exercise] = []

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var chartData: [ChartData] = []
    private let client = ExerciseClient()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text(item.title)
                    .font(.largeTitle)
                    .bold()

                Text(item.value)
                    .font(
                        .system(size: 48, weight: .semibold, design: .rounded)
                    )
                    .monospacedDigit()

                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)

        Chart {
            ForEach(chartData) { day in
                BarMark(
                    x: .value(
                        "day",
                        day.day.formatted(
                            Date.FormatStyle()
                                .day(.twoDigits)
                                .month(.twoDigits)
                        )
                    ),
                    y: .value("value", day.value)
                )
            }
        }.onAppear {
            Task {
                await loadEntries()
                createChartData()
            }
        }
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

    private func createChartData() {
        let d = Dictionary(
            uniqueKeysWithValues: self.entries.map { ($0.date, $0.reps) }
        )

        print(d)

        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"

        chartData = lastNDays(lastDays: 7).map { day in
            ChartData(day: day, value: d[format.string(from: day), default: 0]!)
        }
    }
}

#Preview {
    StatisticsDetailView(
        item: .init(
            title: "push ups",
            value: "10",
            subtitle: "overall",
            rawName: "push ups"
        )
    )
}

func lastNDays(lastDays: Int) -> [Date] {
    let today = Date()
    var array = (0...lastDays).map { offset in
        return Calendar.current.date(byAdding: .day, value: -offset, to: today)!
    }
    array.reverse()
    return array
}

#Playground {
    let format = DateFormatter()
    format.dateFormat = "yyyy-MM-dd"
    let now_date = Date.now
    let formatted_date_string = format.string(from: now_date)
}
