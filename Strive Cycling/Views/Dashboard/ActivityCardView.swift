//
//  ActivityCardView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/18/25.
//

import SwiftUI

struct ActivityCardView: View {
    let activity: Activity

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(activity.name)
                .font(.headline)
            Text("\(activity.distance) km • \(activity.duration) min")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 200)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}


#Preview {
    ActivityCardView(activity: Activity(name: "Example", distance: 50, duration: 40, userName: "userName", activityType: "Ride", activitySubType: "Road", date: Date(), calories: 500, description: "Example activity"))
}
