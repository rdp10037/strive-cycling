//
//  ActivityDetailView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/19/25.
//

import SwiftUI
import CoreLocation

struct ActivityDetailView: View {
    
    @EnvironmentObject var activityVM: StravaActivityViewModel

    let activityId: Int

    @State private var waterMl: Int = 0
    @State private var gels: Double = 0
    @State private var gelType: String = ""
    @State private var bars: Double = 0
    @State private var barType: String = ""
    @State private var perceivedExertionRating: Int = 5
    @State private var notes: String = ""

    @AppStorage("activityNutritionData") private var nutritionData: Data = Data()

    var body: some View {
        
        // MARK: Need to come back to fetch full activity data from the activity_id endpoint rather then the recent activities one
        /// https://developers.strava.com/docs/reference/#api-models-SummaryActivity
        /// https://developers.strava.com/docs/reference/     Get Activity (getActivityById)
        /// https://developers.strava.com/docs/reference/#api-models-DetailedActivity
        
        Form {
            Section {
                Text(activityVM.selectedDetailedActivity?.name ?? "NA")
                            .font(.title2)
                            .bold()
                        if let desc = activityVM.selectedDetailedActivity?.description, !desc.isEmpty {
                            Text(desc)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
            
            Section(header: Text("Activity Summary")) {
                summaryRow("Type", activityVM.selectedDetailedActivity?.type ?? "NA")

                let distanceInMiles = Measurement(value: activityVM.selectedDetailedActivity?.distance ?? 0.0, unit: UnitLength.meters)
                    .converted(to: .miles)
                let formattedDistance = distanceInMiles.formatted(.measurement(width: .abbreviated, usage: .road))
                
                summaryRow("Distance", formattedDistance)
                summaryRow("Duration", "\(Int((activityVM.selectedDetailedActivity?.elapsedTime ?? 0) / 60)) min")
                summaryRow("Start", (activityVM.selectedDetailedActivity?.startDate ?? Date()).formatted(date: .abbreviated, time: .shortened))
                summaryRow("Calories", "\(Int(activityVM.selectedDetailedActivity?.calories ?? 0)) kcal")

                if let hr = activityVM.selectedDetailedActivity?.averageHeartrate {
                    summaryRow("Avg HR", "\(Int(hr)) bpm")
                }
                if let watts = activityVM.selectedDetailedActivity?.averageWatts {
                    summaryRow("Avg Power", "\(Int(watts)) W")
                }
            }

            Section(header: Text("Ride Route")) {
                if let coordinates = activityVM.selectedDetailedActivity?.decodedCoordinates, !coordinates.isEmpty {
                    ActivityMapSnapshotView(coordinates: coordinates)
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
        .task {
            await activityVM.loadDetailedActivity(for: activityId)
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
            id: activityId,
            waterMl: waterMl,
            gels: gels,
            gelType: gelType.isEmpty ? nil : gelType,
            bars: bars,
            barType: barType.isEmpty ? nil : barType,
            perceivedExertionRating: perceivedExertionRating,
            notes: notes.isEmpty ? nil : notes
        )

        if let encoded = try? JSONEncoder().encode(allLogs.merging([String(activityId): log], uniquingKeysWith: { $1 })) {
            nutritionData = encoded
        }
    }

    private func loadSavedLog() {
        let allLogs = loadAllLogs()
        if let existing = allLogs[String(activityId)] {
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
        ActivityDetailView(activityId: 123)
    }
}

