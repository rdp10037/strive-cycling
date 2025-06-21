//
//  ActivityDetailView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/19/25.
//

import SwiftUI
import CoreLocation

struct ActivityDetailView: View {

    let activity: StravaActivity

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
            Section {
                Text(activity.name ?? "NA")
                            .font(.title2)
                            .bold()
                        if let desc = activity.description, !desc.isEmpty {
                            Text(desc)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
            
            Section(header: Text("Activity Summary")) {
                summaryRow("Type", activity.type ?? "NA")

                let distanceInMiles = Measurement(value: activity.distance ?? 0.0, unit: UnitLength.meters)
                    .converted(to: .miles)
                let formattedDistance = distanceInMiles.formatted(.measurement(width: .abbreviated, usage: .road))
                summaryRow("Distance", formattedDistance)

                summaryRow("Duration", "\(Int(activity.duration ?? 0 / 60)) min")
                summaryRow("Start", activity.startDate.formatted(date: .abbreviated, time: .shortened))
                summaryRow("Calories", "\(Int(activity.calories ?? 0)) kcal")

                if let hr = activity.averageHeartRate {
                    summaryRow("Avg HR", "\(Int(hr)) bpm")
                }
                if let watts = activity.averagePower {
                    summaryRow("Avg Power", "\(Int(watts)) W")
                }
            }

            Section(header: Text("Ride Route")) {
                if !activity.decodedCoordinates.isEmpty {
                    ActivityMapSnapshotView(coordinates: activity.decodedCoordinates)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 200)
                        .overlay(Text("No Map Data").foregroundColor(.secondary))
                        .cornerRadius(8)
                }
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
            id: activity.id,
            waterMl: waterMl,
            gels: gels,
            gelType: gelType.isEmpty ? nil : gelType,
            bars: bars,
            barType: barType.isEmpty ? nil : barType,
            perceivedExertionRating: perceivedExertionRating,
            notes: notes.isEmpty ? nil : notes
        )

        if let encoded = try? JSONEncoder().encode(allLogs.merging([activity.id: log], uniquingKeysWith: { $1 })) {
            nutritionData = encoded
        }
    }

    private func loadSavedLog() {
        let allLogs = loadAllLogs()
        if let existing = allLogs[activity.id] {
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

#Preview("StravaActivity View") {
    NavigationStack {
        ActivityDetailView(activity: StravaActivity(
            id: "123456",
            name: "Morning Ride",
            type: "Ride",
            distance: 40233,
            duration: 3780,
            startDate: Date(),
            calories: 850,
            averageHeartRate: 140,
            averagePower: 180,
            polyline: nil,
            startLatitude: 37.7749,
            startLongitude: -122.4194,
            endLatitude: 37.7799,
            endLongitude: -122.4144,
            description: "Felt solid, fast group ride. Next time I would like too go longer.",
            totalElevationGain: 430,
            startDateLocal: Date(),
            timezone: "(GMT-08:00) America/Los_Angeles",
            commute: false,
            trainer: false,
            manual: false,
            locationCity: "San Francisco",
            locationState: "CA",
            locationCountry: "USA",
            elevHigh: 120.5,
            elevLow: 5.2,
            averageSpeed: 5.2,
            maxSpeed: 12.1,
            averageCadence: 82,
            averageTemp: 67,
            sufferScore: 124,
            maxHeartrate: 172,
            hasHeartrate: true,
            deviceWatts: true,
            kilojoules: 950,
            prCount: 3,
            kudosCount: 21
        ))
    }
}
