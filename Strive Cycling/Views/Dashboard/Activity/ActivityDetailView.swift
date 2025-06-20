//
//  ActivityDetailView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/19/25.
//

import SwiftUI

struct ActivityDetailView: View {
    
    let activity: ActivityMetric

    @State private var waterMl: Int = 0
    @State private var gels: Double = 0
    @State private var gelType: String = ""
    @State private var bars: Double = 0
    @State private var barType: String = ""
    @State private var perceivedExertionRating: Int = 5
    @State private var notes: String = ""

    @AppStorage("activityNutritionData") private var nutritionData: Data = Data()

    var body: some View {
        Form {
            Section(header: Text("Activity Summary")) {
                summaryRow("Type", activity.activityType)

                let distanceInMiles = Measurement(value: activity.distance, unit: UnitLength.kilometers)
                    .converted(to: .miles)
                let formattedDistance = distanceInMiles.formatted(.measurement(width: .abbreviated, usage: .road))
                summaryRow("Distance", formattedDistance)

                summaryRow("Duration", "\(Int(activity.duration)) min")
                summaryRow("Start", activity.startTime.formatted(date: .abbreviated, time: .shortened))
                summaryRow("End", activity.endTime.formatted(date: .abbreviated, time: .shortened))
                summaryRow("Calories", "\(activity.calories) kcal")

                if let hr = activity.averageHeartRate {
                    summaryRow("Avg HR", "\(hr) bpm")
                }
                if let watts = activity.averagePower {
                    summaryRow("Avg Power", "\(watts) W")
                }
            }

            Section(header: Text("Ride Route")) {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 200)
                    .overlay(Text("Map Coming Soon").foregroundColor(.secondary))
                    .cornerRadius(8)
            }

            Section(header: Text("Nutrition")) {
                Stepper("Water: \(waterMl) ml", value: $waterMl, in: 0...3000, step: 100)
                Stepper("Gels: \(gels, specifier: "%.1f")", value: $gels, in: 0...10, step: 0.5)
                TextField("Gel Type (optional)", text: $gelType)
                Stepper("Bars: \(bars, specifier: "%.1f")", value: $bars, in: 0...10, step: 0.5)
                TextField("Bar Type (optional)", text: $barType)
            }

            Section(header: Text("Perceived Exertion")) {
                Slider(value: Binding(
                    get: { Double(perceivedExertionRating) },
                    set: { perceivedExertionRating = Int($0) }
                ), in: 1...10, step: 1)
                Text("Felt like: \(perceivedExertionRating)/10")
            }

            Section(header: Text("Notes")) {
                TextEditor(text: $notes)
                    .frame(height: 100)
            }

            Button("Save Log") {
                saveNutritionLog()
            }
        }
        .navigationTitle("Activity Details")
        .onAppear {
            loadSavedLog()
        }
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundColor(.secondary)
        }
    }

    private func saveNutritionLog() {
        var allLogs = loadAllLogs()
        let log = ActivityNutrition(
            id: activity.id.uuidString,
            waterMl: waterMl,
            gels: gels,
            gelType: gelType.isEmpty ? nil : gelType,
            bars: bars,
            barType: barType.isEmpty ? nil : barType,
            perceivedExertionRating: perceivedExertionRating,
            notes: notes.isEmpty ? nil : notes
        )

        if let encoded = try? JSONEncoder().encode(allLogs.merging([activity.id.uuidString: log], uniquingKeysWith: { $1 })) {
            nutritionData = encoded
        }
    }

    private func loadSavedLog() {
        let allLogs = loadAllLogs()
        if let existing = allLogs[activity.id.uuidString] {
            waterMl = existing.waterMl ?? 0
            gels = existing.gels ?? 0
            gelType = existing.gelType ?? ""
            bars = existing.bars ?? 0
            barType = existing.barType ?? ""
            perceivedExertionRating = existing.perceivedExertionRating ?? 5
            notes = existing.notes ?? ""
        }
    }

    private func loadAllLogs() -> [String: ActivityNutrition] {
        if let decoded = try? JSONDecoder().decode([String: ActivityNutrition].self, from: nutritionData) {
            return decoded
        }
        return [:]
    }
}



#Preview("Metric-Based View") {
    NavigationStack {
        ActivityDetailView(activity: ActivityMetric(
            id: UUID(),
            name: "Morning Ride",
            distance: 42.7,
            duration: 88,
            userName: "Rob",
            activityType: "Ride",
            activitySubType: nil,
            date: .now.addingTimeInterval(-5400),
            calories: 740,
            description: "Felt solid, fast group ride.",
            averageHeartRate: 145,
            averagePower: 218
        ))
    }
}


