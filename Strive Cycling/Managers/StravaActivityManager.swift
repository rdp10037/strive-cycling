//
//  StravaActivityManager.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/20/25.
//

import Foundation
import CoreLocation

// MARK: Old StravaActivity Struct
//struct StravaActivity: Identifiable, Codable {
//    let id: String      // Required
//    let name: String?
//    let type: String?
//    let distance: Double?
//    let duration: Double?
//    let startDate: Date  // Required
//    let calories: Double?
//    let averageHeartRate: Double?
//    let averagePower: Double?
//    let polyline: String?
//    let startLatitude: Double?
//    let startLongitude: Double?
//    let endLatitude: Double?
//    let endLongitude: Double?
//    let description: String?
//    let totalElevationGain: Double?
//    let startDateLocal: Date?
//    let timezone: String?
//    let commute: Bool?
//    let trainer: Bool?
//    let manual: Bool?
//    let locationCity: String?
//    let locationState: String?
//    let locationCountry: String?
//    let elevHigh: Double?
//    let elevLow: Double?
//    let averageSpeed: Double?
//    let maxSpeed: Double?
//    let averageCadence: Double?
//    let averageTemp: Double?
//    let sufferScore: Double?
//    let maxHeartrate: Double?
//    let hasHeartrate: Bool?
//    let deviceWatts: Bool?
//    let kilojoules: Double?
//    let prCount: Int?
//    let kudosCount: Int?
//    
//    var decodedCoordinates: [CLLocationCoordinate2D] {
//        guard let polyline = polyline else { return [] }
//        return decodePolyline(polyline)
//    }
//    
//    var startCoordinate: CLLocationCoordinate2D? {
//        guard let lat = startLatitude, let lon = startLongitude else { return nil }
//        return .init(latitude: lat, longitude: lon)
//    }
//    
//    var endCoordinate: CLLocationCoordinate2D? {
//        guard let lat = endLatitude, let lon = endLongitude else { return nil }
//        return .init(latitude: lat, longitude: lon)
//    }
//}

// MARK: Strava Activity from /activities endpoint
struct StravaActivity: Identifiable, Codable {
    let id: Int
    let name: String?
    let type: String?
    let sportType: String?  // e.g. "Ride", "VirtualRide"
    let distance: Double?
    let movingTime: Int?
    let elapsedTime: Int?
    let totalElevationGain: Double?
    let startDate: Date
    let startDateLocal: Date?
    let timezone: String?
    let averageSpeed: Double?
    let maxSpeed: Double?
    let averageCadence: Double?
    let averageTemp: Double?
    let averageWatts: Double?
    let deviceWatts: Bool?
    let kilojoules: Double?
    let hasHeartrate: Bool?
    let averageHeartrate: Double?
    let maxHeartrate: Double?
    let commute: Bool?
    let trainer: Bool?
    let manual: Bool?
    let prCount: Int?
    let kudosCount: Int?
    let sufferScore: Double?
    let description: String?
    let locationCity: String?
    let locationState: String?
    let locationCountry: String?
    let startLatlng: [Double]?
    let endLatlng: [Double]?
    
    let map: StravaMap?

    struct StravaMap: Codable {
        let id: String?
        let summaryPolyline: String?
    }
    
    var polyline: String? {
        map?.summaryPolyline
    }

    var startCoordinate: CLLocationCoordinate2D? {
        guard let lat = startLatlng?.first, let lon = startLatlng?.last else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var endCoordinate: CLLocationCoordinate2D? {
        guard let lat = endLatlng?.first, let lon = endLatlng?.last else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var decodedCoordinates: [CLLocationCoordinate2D] {
        guard let polyline = polyline else { return [] }
        return decodePolyline(polyline)
    }
}

// MARK: Detailed Activity from /activities/{id} endpoint
struct StravaDetailedActivity: Identifiable, Codable {
    let id: Int
    let externalId: String?
    let uploadId: Int?
    let uploadIdStr: String?
    let name: String
    let description: String?
    let distance: Double
    let movingTime: Int
    let elapsedTime: Int
    let totalElevationGain: Double
    let elevHigh: Double?
    let elevLow: Double?
    let type: String
    let sportType: String?
    let startDate: Date
    let startDateLocal: Date
    let timezone: String?
    let utcOffset: Double?
    let startLatlng: [Double]?
    let endLatlng: [Double]?
    let achievementCount: Int?
    let kudosCount: Int?
    let commentCount: Int?
    let athleteCount: Int?
    let photoCount: Int?
    let totalPhotoCount: Int?
    let trainer: Bool?
    let commute: Bool?
    let manual: Bool?
    let `private`: Bool?
    let flagged: Bool?
    let workoutType: Int?
    let averageSpeed: Double?
    let maxSpeed: Double?
    let averageCadence: Double?
    let averageTemp: Int?
    let averageWatts: Double?
    let weightedAverageWatts: Int?
    let kilojoules: Double?
    let deviceWatts: Bool?
    let hasHeartrate: Bool?
    let averageHeartrate: Double?
    let maxHeartrate: Double?
    let calories: Double?
    let gearId: String?
    let map: StravaMap?
    let athlete: MetaAthlete?
    let gear: SummaryGear?
    let segmentEfforts: [DetailedSegmentEffort]?
    let splitsMetric: [Split]?
    let splitsStandard: [Split]?
    let laps: [Lap]?
    let photos: PhotosSummary?
    let deviceName: String?
    let embedToken: String?

    var polyline: String? {
        map?.summaryPolyline
    }

    var decodedCoordinates: [CLLocationCoordinate2D] {
        guard let polyline = polyline else { return [] }
        return decodePolyline(polyline)
    }
}

// MARK: - Nested Types
struct MetaAthlete: Codable {
    let id: Int
    let resourceState: Int?
}

struct StravaMap: Codable {
    let id: String?
    let polyline: String?
    let summaryPolyline: String?
}

struct SummaryGear: Codable {
    let id: String
    let primary: Bool?
    let name: String?
    let resourceState: Int?
    let distance: Double?
}

struct DetailedSegmentEffort: Codable {
    let id: Int
    let name: String?
    let elapsedTime: Int?
    let movingTime: Int?
    let startDate: Date?
    let startDateLocal: Date?
    let distance: Double?
    let averageCadence: Double?
    let deviceWatts: Bool?
    let averageWatts: Double?
    let segment: Segment?
}

struct Segment: Codable {
    let id: Int
    let name: String?
    let activityType: String?
    let distance: Double?
    let averageGrade: Double?
    let maximumGrade: Double?
    let elevationHigh: Double?
    let elevationLow: Double?
    let startLatlng: [Double]?
    let endLatlng: [Double]?
    let climbCategory: Int?
    let city: String?
    let state: String?
    let country: String?
    let `private`: Bool?
}

struct Split: Codable {
    let distance: Double
    let elapsedTime: Int
    let elevationDifference: Double?
    let movingTime: Int
    let split: Int
    let averageSpeed: Double
    let paceZone: Int?
}

struct Lap: Codable {
    let id: Int
    let name: String?
    let elapsedTime: Int?
    let movingTime: Int?
    let startDate: Date?
    let startDateLocal: Date?
    let distance: Double?
    let totalElevationGain: Double?
    let averageSpeed: Double?
    let maxSpeed: Double?
    let averageCadence: Double?
    let averageWatts: Double?
    let lapIndex: Int?
    let split: Int?
}

struct PhotosSummary: Codable {
    let count: Int?
    let primary: PrimaryPhoto?
    let usePrimaryPhoto: Bool?
}

struct PrimaryPhoto: Codable {
    let uniqueId: String?
    let urls: [String: String]?
    let source: Int?
}


enum StravaError: Error {
    case invalidURL
    case invalidResponse
    case invalidToken
}

// MARK: Strava Activity Manager
final class StravaActivityManager {
    
    static let shared = StravaActivityManager()
    
    private let baseURL = "https://www.strava.com/api/v3"
    
    
    /// Fetch given count of recent fitness activities from Strava.
    ///
    /// Fetches a specified number of recent activities from the Strava /athlete/activities endpoint and converts them to ``StravaActivity`` for use in the app.
    ///
    /// > Tip: This endpoint's data does not always contain complete activity info. For example, while it does contain most values you would expect about an activity, calorie data is missing. To fetch more granular data you must use an activity ID and fetch the specific activity via the appropriate Strava endpoint.
    ///
    /// - Parameter count: The desired count of recent activities as an `Int`. Subject to Strava's page count limit of 200 as of June 2025.
    /// - Returns: Returns an  `Array` of ``StravaActivity``.
    func fetchRecentActivitiesWithCount(count: Int) async throws -> [StravaActivity] {
        let token = try await ensureValidToken()
        guard let url = URL(string: "\(baseURL)/athlete/activities?per_page=\(count)") else {
            throw StravaError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw StravaError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode([StravaActivity].self, from: data)
    }
    
    /// Fetches a detailed activity object from the Strava API using the provided activity ID.
    ///
    /// This method calls the `/activities/{id}` endpoint to retrieve a fully detailed activity,
    /// including fields not available in the `/athlete/activities` list endpoint, such as:
    /// - Calories
    /// - Gear
    /// - Segment efforts
    /// - Splits and laps
    ///
    /// It requires a valid access token and automatically refreshes the token if needed.
    /// The returned object is decoded into a `StravaDetailedActivity` model using `JSONDecoder`.
    ///
    /// - Parameter id: The unique Strava activity ID to fetch details for.
    /// - Returns: A fully populated `StravaDetailedActivity` instance.
    /// - Throws:
    ///   - `StravaError.invalidURL` if the constructed URL is malformed.
    ///   - `StravaError.invalidResponse` if the server response is not HTTP 200.
    ///   - Any decoding or network error encountered during the request.
    /// - Note: Ensure that this function is called from within an async context.
    func fetchDetailedActivity(by id: Int) async throws -> StravaDetailedActivity {
        let token = try await ensureValidToken()
        guard let url = URL(string: "\(baseURL)/activities/\(id)") else {
            throw StravaError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw StravaError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(StravaDetailedActivity.self, from: data)
    }

    
    /// Ensures that a valid Strava access token is available before making API requests.
    ///
    /// If the current token exists and has not expired, it is returned.
    /// Otherwise, this method attempts to refresh the token and return the new value.
    ///
    /// - Returns: A valid Strava access token as a `String`.
    /// - Throws: An error if token refresh fails or a valid token cannot be obtained.
    private func ensureValidToken() async throws -> String {
        if let token = await StravaAuthManager.shared.accessToken,
           let expiration = await StravaAuthManager.shared.tokenExpiration,
           Date() < expiration {
            return token
        }

        let success = await StravaAuthManager.shared.refreshAccessToken()

        guard success, let newToken = await StravaAuthManager.shared.accessToken else {
            throw NSError(domain: "StravaAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token refresh failed"])
        }

        return newToken
    }

    
    
    /// Parse Strava activity JSON data
    ///
    /// ``StravaActivity`` requires an ID and startDate. As such we first ensure they are present or else return out of the function. StartData is further refined here for simpler use in our desired return object.
    ///
    /// Strava API provides start and end locations as an [Double]. However,   ``StravaActivity`` utilizes individual values. Thus, we must first create the necessary local [Double] value before utilizing the desired array value using .first or .last notion.
    ///
    /// - Parameter dict: Parsing with a diction [String: Any]
    /// - Returns: Returns the desired ``StravaActivity``
//    private func parseActivity(from dict: [String: Any]) -> StravaActivity? {
//        guard
//            let id = dict["id"] as? Int,
//            let startDateStr = dict["start_date"] as? String,
//            let startDate = ISO8601DateFormatter().date(from: startDateStr)
//        else {
//            return nil
//        }
// 
//        let startLatLng = dict["start_latlng"] as? [Double]
//        let endLatLng = dict["end_latlng"] as? [Double]
//        
//        return StravaActivity(
//            id: String(id),
//            name: dict["name"] as? String,
//            type: dict["type"] as? String,
//            distance: dict["distance"] as? Double,
//            duration: dict["elapsed_time"] as? Double,
//            startDate: startDate,
//            calories: dict["calories"] as? Double,
//            averageHeartRate: dict["average_heartrate"] as? Double,
//            averagePower: dict["average_watts"] as? Double,
//            polyline: ((dict["map"] as? [String: Any])?["summary_polyline"] as? String),
//            startLatitude: startLatLng?.first,
//            startLongitude: startLatLng?.last,
//            endLatitude: endLatLng?.first,
//            endLongitude: endLatLng?.last,
//            description: dict["description"] as? String,
//            totalElevationGain: dict["total_elevation_gain"] as? Double,
//            startDateLocal: ISO8601DateFormatter().date(from: dict["start_date_local"] as? String ?? ""),
//            timezone: dict["timezone"] as? String,
//            commute: dict["commute"] as? Bool,
//            trainer: dict["trainer"] as? Bool,
//            manual: dict["manual"] as? Bool,
//            locationCity: dict["location_city"] as? String,
//            locationState: dict["location_state"] as? String,
//            locationCountry: dict["location_country"] as? String,
//            elevHigh: dict["elev_high"] as? Double,
//            elevLow: dict["elev_low"] as? Double,
//            averageSpeed: dict["average_speed"] as? Double,
//            maxSpeed: dict["max_speed"] as? Double,
//            averageCadence: dict["average_cadence"] as? Double,
//            averageTemp: dict["average_temp"] as? Double,
//            sufferScore: dict["suffer_score"] as? Double,
//            maxHeartrate: dict["max_heartrate"] as? Double,
//            hasHeartrate: dict["has_heartrate"] as? Bool,
//            deviceWatts: dict["device_watts"] as? Bool,
//            kilojoules: dict["kilojoules"] as? Double,
//            prCount: dict["pr_count"] as? Int,
//            kudosCount: dict["kudos_count"] as? Int
//        )
//    }
    
    
   
}
