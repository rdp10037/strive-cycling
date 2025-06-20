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
                        Text(activity.name)
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

                    Text(activity.type)
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
                    VStack(alignment: .leading) {
                        HStack {
                            Text(String(format: "%.1f", activity.distance / 1609.34)) // meters to miles
                                .font(.headline)
                            Text("mi")
                                .font(.subheadline)
                        }
                        Text("Distance")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading) {
                        HStack {
                            Text(String(format: "%.0f", activity.duration / 60)) // seconds to minutes
                                .font(.headline)
                            Text("min")
                                .font(.subheadline)
                        }
                        Text("Duration")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading) {
                        HStack {
                            Text(String(format: "%.0f", activity.calories ?? 0))
                                .font(.headline)
                            Text("kcal")
                                .font(.subheadline)
                        }
                        Text("Energy")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
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
        id: "123456",
        name: "Morning Ride",
        type: "Ride",
        distance: 40233.0, // ~25 miles
        duration: 3780.0,  // ~63 minutes
        startDate: Date(),
        calories: 850.0,
        averageHeartRate: 142.5,
        averagePower: 185.0,
        polyline: nil,
        startLatitude: 37.7749,
        startLongitude: -122.4194,
        endLatitude: 37.8049,
        endLongitude: -122.4294,
        description: "Rode through Golden Gate Park and up Twin Peaks.",
        totalElevationGain: 450.0,
        startDateLocal: Date(),
        timezone: "America/Los_Angeles",
        commute: false,
        trainer: false,
        manual: false,
        locationCity: "San Francisco",
        locationState: "CA",
        locationCountry: "USA",
        elevHigh: 302.4,
        elevLow: 15.2,
        averageSpeed: 5.9,
        maxSpeed: 12.8,
        averageCadence: 87.0,
        averageTemp: 65.0,
        sufferScore: 75.0,
        maxHeartrate: 174.0,
        hasHeartrate: true,
        deviceWatts: true,
        kilojoules: 680.0,
        prCount: 3,
        kudosCount: 19
    ))
}

