//
//  MockData.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/18/25.
//

import Foundation

struct Activity: Identifiable {
    let id = UUID()
    let name: String
    let distance: Double
    let duration: Double
    let userName: String
    let activityType: String
    let activitySubType: String?
    let date: Date
    let calories: Int
    let description: String
    

    static func mockToday() -> [Activity] {
        [
            Activity(name: "Morning Ride", distance: 28, duration: 55, userName: "rob", activityType: "Ride", activitySubType: "Road", date: Date(), calories: 450, description: "Sunny and perfect"),
            Activity(name: "Lunch Spin", distance: 12, duration: 30, userName: "rob", activityType: "Ride", activitySubType: "Road", date: Date(), calories: 200, description: "Light and easy")
        ]
    }

    static func mockFriends() -> [Activity] {
        [
            Activity(name: "Beach Loop", distance: 42, duration: 80, userName: "Alex", activityType: "Ride", activitySubType: "Road", date: Date(), calories: 600, description: "Hot and humid"),
            Activity(name: "Commute", distance: 16, duration: 40, userName: "Jordan", activityType: "Ride", activitySubType: "Road", date: Date(), calories: 150, description: "Cold and snowy"),
            Activity(name: "Sunset Ride", distance: 35, duration: 60, userName: "Casey", activityType: "Ride", activitySubType: "Road", date: Date(), calories: 500, description: "Beautiful sunset")
        ]
    }
    
    static func mockHistoricalData() -> [Activity] {
        var array: [Activity] = []
        
        for i in 0..<7 {
            let data = Activity(name: "Test \(i)", distance: Double.random(in: 0...200), duration: Double.random(in: 0...400), userName: "rob", activityType: "Ride", activitySubType: "Road", date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!, calories: Int.random(in: 0...10000), description: "Example description \(i)")
            array.append(data)
        }
        return array
    }
}
