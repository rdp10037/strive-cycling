//
//  StravaManager.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/19/25.
//

import Foundation


struct ActivityMetric: Identifiable, Codable {
    let id: UUID
    let name: String
    let distance: Double       // in kilometers
    let duration: Double       // in minutes
    let userName: String
    let activityType: String
    let activitySubType: String?
    let date: Date
    let calories: Int
    let description: String

    // New metrics
    let averageHeartRate: Int?
    let averagePower: Int?
    
    // Optional: Computed properties
    var startTime: Date { date }
    var endTime: Date { date.addingTimeInterval(duration * 60) }
}
 
