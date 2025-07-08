//
//  StravaActivityRowView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/20/25.
//

import SwiftUI

struct StravaActivityRowView: View {
    
    let activity: StravaActivity

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "mappin")

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(activity.name ?? "Untitled")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(activity.startDate, format: .dateTime.day().month().year())
                        Spacer()

                        Image(systemName: "chevron.right")
                            .padding(.trailing, 10)
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                    Text(activity.sportType ?? activity.type ?? "Ride")
                        .font(.body)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }

            HStack {
                ActivityMapSnapshotView(coordinates: activity.decodedCoordinates)
                    .frame(width: UIScreen.main.bounds.width * 0.6, height: 160)

                VStack(alignment: .leading, spacing: 8) {
                    
                    // Distance
                    let distanceInMiles = Measurement(value: activity.distance ?? 0.0, unit: UnitLength.meters)
                        .converted(to: .miles)
                    let formattedDistance = distanceInMiles.formatted(.measurement(width: .abbreviated, usage: .road))

                    VStack(alignment: .leading) {
                        Text(formattedDistance)
                            .font(.headline)
                        Text("Distance")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    // Duration (from movingTime)
                    if let movingTime = activity.movingTime {
                        let minutes = Int(movingTime) / 60
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(minutes)")
                                    .font(.headline)
                                Text("min")
                                    .font(.subheadline)
                            }
                            Text("Moving Time")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Average Power (from averageWatts)
                    if let watts = activity.averageWatts {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(Int(watts))")
                                    .font(.headline)
                                Text("w")
                                    .font(.subheadline)
                            }
                            Text("Avg Power")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(minWidth: 90, minHeight: 160)

                Spacer()
            }
        }
    }
}



#Preview {
    StravaActivityRowView(activity: StravaActivity(
        id: 123456,
        name: "Morning Ride",
        type: "Ride",
        sportType: "VirtualRide",
        distance: 40233.0,
        movingTime: 3780,
        elapsedTime: 4000,
        totalElevationGain: 450.0,
        startDate: Date(),
        startDateLocal: Date(),
        timezone: "America/Los_Angeles",
        averageSpeed: 5.9,
        maxSpeed: 12.8,
        averageCadence: 87.0,
        averageTemp: 65.0,
        averageWatts: 185.0,
        deviceWatts: true,
        kilojoules: 680.0,
        hasHeartrate: true,
        averageHeartrate: 142.5,
        maxHeartrate: 174.0,
        commute: false,
        trainer: true,
        manual: false,
        prCount: 3,
        kudosCount: 19,
        sufferScore: 75,
        description: "Rode through Golden Gate Park and up Twin Peaks.",
        locationCity: "San Francisco",
        locationState: "CA",
        locationCountry: "USA",
        startLatlng: [37.7749, -122.4194],
        endLatlng: [37.8049, -122.4294],
        map: .init(id: "map123", summaryPolyline: nil)
    ))
}
