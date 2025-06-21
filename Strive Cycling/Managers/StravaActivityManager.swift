//
//  StravaActivityManager.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/20/25.
//

import Foundation
import CoreLocation

struct StravaActivity: Identifiable, Codable {
    let id: String
    let name: String
    let type: String
    let distance: Double
    let duration: Double
    let startDate: Date
    let calories: Double?
    let averageHeartRate: Double?
    let averagePower: Double?
    
    let polyline: String?
    let startLatitude: Double?
    let startLongitude: Double?
    let endLatitude: Double?
    let endLongitude: Double?
    
    let description: String?
    let totalElevationGain: Double?
    let startDateLocal: Date?
    let timezone: String?
    let commute: Bool?
    let trainer: Bool?
    let manual: Bool?
    let locationCity: String?
    let locationState: String?
    let locationCountry: String?
    let elevHigh: Double?
    let elevLow: Double?
    let averageSpeed: Double?
    let maxSpeed: Double?
    let averageCadence: Double?
    let averageTemp: Double?
    let sufferScore: Double?
    let maxHeartrate: Double?
    let hasHeartrate: Bool?
    let deviceWatts: Bool?
    let kilojoules: Double?
    let prCount: Int?
    let kudosCount: Int?
    
    var decodedCoordinates: [CLLocationCoordinate2D] {
        guard let polyline = polyline else { return [] }
        return decodePolyline(polyline)
    }
    
    var startCoordinate: CLLocationCoordinate2D? {
        guard let lat = startLatitude, let lon = startLongitude else { return nil }
        return .init(latitude: lat, longitude: lon)
    }
    
    var endCoordinate: CLLocationCoordinate2D? {
        guard let lat = endLatitude, let lon = endLongitude else { return nil }
        return .init(latitude: lat, longitude: lon)
    }
}

final class StravaActivityManager {
    static let shared = StravaActivityManager()
    
    private let baseURL = "https://www.strava.com/api/v3"
    
    func fetchRecentActivitiesAsync(count: Int) async throws -> [StravaActivity] {
        let token = try await ensureValidToken()
        
        let urlString = "\(baseURL)/athlete/activities?per_page=\(count)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw NSError(domain: "Invalid JSON", code: -1)
        }
        
        var activities: [StravaActivity] = []
        for dict in jsonArray {
            if let activity = parseActivity(from: dict) {
                print("\n📌 Activity: \(activity.name)")
                print("ID: \(activity.id)")
                print("Type: \(activity.type)")
                print("Distance: \(activity.distance) meters")
                print("Duration: \(activity.duration) seconds")
                print("Start Date: \(activity.startDate)")
                print("Calories: \(activity.calories ?? 0)")
                print("Heart Rate: \(activity.averageHeartRate ?? 0)")
                print("Power: \(activity.averagePower ?? 0)")
                activities.append(activity)
            }
        }
        return activities
    }
    
    private func ensureValidToken() async throws -> String {
        if let token = await StravaAuthManager.shared.accessToken,
           let expiration = await StravaAuthManager.shared.tokenExpiration,
           Date() < expiration {
            return token
        }
        
        let token = try await withCheckedThrowingContinuation { continuation in
            StravaAuthManager.shared.refreshAccessToken { success in
                if success, let token = StravaAuthManager.shared.accessToken {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: NSError(domain: "Token refresh failed", code: -1))
                }
            }
        }
        return token
    }
    
    private func parseActivity(from dict: [String: Any]) -> StravaActivity? {
        guard
            let id = dict["id"] as? Int,
            let name = dict["name"] as? String,
            let type = dict["type"] as? String,
            let distance = dict["distance"] as? Double,
            let duration = dict["elapsed_time"] as? Double,
            let startDateStr = dict["start_date"] as? String,
            let startDate = ISO8601DateFormatter().date(from: startDateStr)
        else {
            return nil
        }
        
        let startLatLng = dict["start_latlng"] as? [Double]
        let endLatLng = dict["end_latlng"] as? [Double]
        
        return StravaActivity(
            id: String(id),
            name: name,
            type: type,
            distance: distance,
            duration: duration,
            startDate: startDate,
            calories: dict["calories"] as? Double,
            averageHeartRate: dict["average_heartrate"] as? Double,
            averagePower: dict["average_watts"] as? Double,
            polyline: ((dict["map"] as? [String: Any])?["summary_polyline"] as? String),
            startLatitude: startLatLng?.first,
            startLongitude: startLatLng?.last,
            endLatitude: endLatLng?.first,
            endLongitude: endLatLng?.last,
            description: dict["description"] as? String,
            totalElevationGain: dict["total_elevation_gain"] as? Double,
            startDateLocal: ISO8601DateFormatter().date(from: dict["start_date_local"] as? String ?? ""),
            timezone: dict["timezone"] as? String,
            commute: dict["commute"] as? Bool,
            trainer: dict["trainer"] as? Bool,
            manual: dict["manual"] as? Bool,
            locationCity: dict["location_city"] as? String,
            locationState: dict["location_state"] as? String,
            locationCountry: dict["location_country"] as? String,
            elevHigh: dict["elev_high"] as? Double,
            elevLow: dict["elev_low"] as? Double,
            averageSpeed: dict["average_speed"] as? Double,
            maxSpeed: dict["max_speed"] as? Double,
            averageCadence: dict["average_cadence"] as? Double,
            averageTemp: dict["average_temp"] as? Double,
            sufferScore: dict["suffer_score"] as? Double,
            maxHeartrate: dict["max_heartrate"] as? Double,
            hasHeartrate: dict["has_heartrate"] as? Bool,
            deviceWatts: dict["device_watts"] as? Bool,
            kilojoules: dict["kilojoules"] as? Double,
            prCount: dict["pr_count"] as? Int,
            kudosCount: dict["kudos_count"] as? Int
        )
    }
}
