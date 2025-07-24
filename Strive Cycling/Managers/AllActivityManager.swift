//
//  AllActivityManager.swift
//  Strive Cycling
//
//  Created by Rob Pee on 7/24/25.
//

import Foundation
import FirebaseFirestore

//struct UserActivity: Codable, Identifiable {
//    let id: String
//    let source: String? // Strava, HealthKit, Zwift, manual etc
//    let name: String?
//    let type: String?
//    let startDate: Date?
//    let duration: Double?
//    let distance: Double?
//    let calories: Double?
//    let averageHeartRate: Double?
//    let maxHeartRate: Double?
//    let averageWatts: Double?
//    let maxWatts: Double?
//    let polyline: String?
//    let startLatitude: Double?
//    let startLongitude: Double?
//    let endLatitude: Double?
//    let endLongitude: Double?
//    let totalElevationGain: Double?
//    let elevHigh: Double?
//    let elevLow: Double?
//    let deviceName: String?
//    
//// nutrition
//    let waterMl: Int?
//    let gels: Double?
//    let gelType: String?
//    let bars: Double?
//    let barType: String?
//    let perceivedExertionRating: Int?
//    let notes: String?
//    
//    let stravaAthleteId: String?
//    
//    
//    // MARK: - Custom initializer for new activity creation
//    init(
//        id: String,
//        source: String? = nil,
//        name: String? = nil,
//        type: String? = nil,
//        startDate: Date? = nil,
//        duration: Double? = nil,
//        distance: Double? = nil,
//        calories: Double? = nil,
//        averageHeartRate: Double? = nil,
//        maxHeartRate: Double? = nil,
//        averageWatts: Double? = nil,
//        maxWatts: Double? = nil,
//        polyline: String? = nil,
//        startLatitude: Double? = nil,
//        startLongitude: Double? = nil,
//        endLatitude: Double? = nil,
//        endLongitude: Double? = nil,
//        totalElevationGain: Double? = nil,
//        elevHigh: Double? = nil,
//        elevLow: Double? = nil,
//        deviceName: String? = nil,
//        waterMl: Int? = nil,
//        gels: Double? = nil,
//        gelType: String? = nil,
//        bars: Double? = nil,
//        barType: String? = nil,
//        perceivedExertionRating: Int? = nil,
//        notes: String? = nil,
//        stravaAthleteId: String? = nil
//    ) {
//        self.id = id
//        self.source = source
//        self.name = name
//        self.type = type
//        self.startDate = startDate
//        self.duration = duration
//        self.distance = distance
//        self.calories = calories
//        self.averageHeartRate = averageHeartRate
//        self.maxHeartRate = maxHeartRate
//        self.averageWatts = averageWatts
//        self.maxWatts = maxWatts
//        self.polyline = polyline
//        self.startLatitude = startLatitude
//        self.startLongitude = startLongitude
//        self.endLatitude = endLatitude
//        self.endLongitude = endLongitude
//        self.totalElevationGain = totalElevationGain
//        self.elevHigh = elevHigh
//        self.elevLow = elevLow
//        self.deviceName = deviceName
//        self.waterMl = waterMl
//        self.gels = gels
//        self.gelType = gelType
//        self.bars = bars
//        self.barType = barType
//        self.perceivedExertionRating = perceivedExertionRating
//        self.notes = notes
//        self.stravaAthleteId = stravaAthleteId
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "activity_id"
//        case source = "source"
//        case name = "name"
//        case type = "type"
//        case startDate = "start_date"
//        case duration = "duration"
//        case distance = "distance"
//        case calories = "calories"
//        case averageHeartRate = "average_hr"
//        case maxHeartRate = "max_hr"
//        case averageWatts = "avg_watts"
//        case maxWatts = "max_watts"
//        case polyline = "map_polyline"
//        
//        case startLatitude = "start_lat"
//        case startLongitude = "start_lng"
//        case endLatitude = "end_lat"
//        case endLongitude = "end_lng"
//        
//        case totalElevationGain = "elevation_gain"
//        case elevHigh = "elev_high"
//        case elevLow = "elev_low"
//        
//        case deviceName = "device_name"
//        
//        case waterMl = "water_ml"
//        case gels = "gels"
//        case gelType = "gel_type"
//        case bars = "bars"
//        case barType = "bar_type"
//        case perceivedExertionRating = "perceived_exertion"
//        case notes = "notes"
//        
//        case stravaAthleteId = "strava_athlete_id"
//    }
//    
//    // MARK: - Custom Decoder
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(String.self, forKey: .id)
//        source = try container.decodeIfPresent(String.self, forKey: .source)
//        name = try container.decodeIfPresent(String.self, forKey: .name)
//        type = try container.decodeIfPresent(String.self, forKey: .type)
//        startDate = try container.decodeIfPresent(Date.self, forKey: .startDate)
//        duration = try container.decodeIfPresent(Double.self, forKey: .duration)
//        distance = try container.decodeIfPresent(Double.self, forKey: .distance)
//        calories = try container.decodeIfPresent(Double.self, forKey: .calories)
//        averageHeartRate = try container.decodeIfPresent(Double.self, forKey: .averageHeartRate)
//        maxHeartRate = try container.decodeIfPresent(Double.self, forKey: .maxHeartRate)
//        averageWatts = try container.decodeIfPresent(Double.self, forKey: .averageWatts)
//        maxWatts = try container.decodeIfPresent(Double.self, forKey: .maxWatts)
//        polyline = try container.decodeIfPresent(String.self, forKey: .polyline)
//        startLatitude = try container.decodeIfPresent(Double.self, forKey: .startLatitude)
//        startLongitude = try container.decodeIfPresent(Double.self, forKey: .startLongitude)
//        endLatitude = try container.decodeIfPresent(Double.self, forKey: .endLatitude)
//        endLongitude = try container.decodeIfPresent(Double.self, forKey: .endLongitude)
//        totalElevationGain = try container.decodeIfPresent(Double.self, forKey: .totalElevationGain)
//        elevHigh = try container.decodeIfPresent(Double.self, forKey: .elevHigh)
//        elevLow = try container.decodeIfPresent(Double.self, forKey: .elevLow)
//        deviceName = try container.decodeIfPresent(String.self, forKey: .deviceName)
//        
//        waterMl = try container.decodeIfPresent(Int.self, forKey: .waterMl)
//        gels = try container.decodeIfPresent(Double.self, forKey: .gels)
//        gelType = try container.decodeIfPresent(String.self, forKey: .gelType)
//        bars = try container.decodeIfPresent(Double.self, forKey: .bars)
//        barType = try container.decodeIfPresent(String.self, forKey: .barType)
//        perceivedExertionRating = try container.decodeIfPresent(Int.self, forKey: .perceivedExertionRating)
//        notes = try container.decodeIfPresent(String.self, forKey: .notes)
//        
//        stravaAthleteId = try container.decodeIfPresent(String.self, forKey: .stravaAthleteId)
//    }
//    
//    // MARK: - Custom Encoder
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encodeIfPresent(source, forKey: .source)
//        try container.encodeIfPresent(name, forKey: .name)
//        try container.encodeIfPresent(type, forKey: .type)
//        try container.encodeIfPresent(startDate, forKey: .startDate)
//        try container.encodeIfPresent(duration, forKey: .duration)
//        try container.encodeIfPresent(distance, forKey: .distance)
//        try container.encodeIfPresent(calories, forKey: .calories)
//        try container.encodeIfPresent(averageHeartRate, forKey: .averageHeartRate)
//        try container.encodeIfPresent(maxHeartRate, forKey: .maxHeartRate)
//        try container.encodeIfPresent(averageWatts, forKey: .averageWatts)
//        try container.encodeIfPresent(maxWatts, forKey: .maxWatts)
//        try container.encodeIfPresent(polyline, forKey: .polyline)
//        try container.encodeIfPresent(startLatitude, forKey: .startLatitude)
//        try container.encodeIfPresent(startLongitude, forKey: .startLongitude)
//        try container.encodeIfPresent(endLatitude, forKey: .endLatitude)
//        try container.encodeIfPresent(endLongitude, forKey: .endLongitude)
//        try container.encodeIfPresent(totalElevationGain, forKey: .totalElevationGain)
//        try container.encodeIfPresent(elevHigh, forKey: .elevHigh)
//        try container.encodeIfPresent(elevLow, forKey: .elevLow)
//        try container.encodeIfPresent(deviceName, forKey: .deviceName)
//        try container.encodeIfPresent(waterMl, forKey: .waterMl)
//        try container.encodeIfPresent(gels, forKey: .gels)
//        try container.encodeIfPresent(gelType, forKey: .gelType)
//        try container.encodeIfPresent(bars, forKey: .bars)
//        try container.encodeIfPresent(barType, forKey: .barType)
//        try container.encodeIfPresent(perceivedExertionRating, forKey: .perceivedExertionRating)
//        try container.encodeIfPresent(notes, forKey: .notes)
//        
//        try container.encodeIfPresent(stravaAthleteId, forKey: .stravaAthleteId)
//    }
//}

struct UserActivityMetaData: Codable, Identifiable, Hashable {
    
    let id: String
    let dateCreated: Date?
    let activityRefId: String?
    let waterMl: Int?
    let gels: Double?
    let gelType: String?
    let bars: Double?
    let barType: String?
    let perceivedExertionRating: Int?
    let notes: String?
    
    init () {
        self.id = ""
        self.dateCreated = Date()
        self.activityRefId = ""
        self.waterMl = nil
        self.gels = nil
        self.gelType = nil
        self.bars = nil
        self.barType = nil
        self.perceivedExertionRating = nil
        self.notes = nil
    }
    init (
        id: String,
        dateCreated: Date? = nil,
        activityRefId: String? = nil,
        waterMl: Int? = nil,
        gels: Double? = nil,
        gelType: String? = nil,
        bars: Double? = nil,
        barType: String? = nil,
        perceivedExertionRating: Int? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.dateCreated = dateCreated
        self.activityRefId = activityRefId
        self.waterMl = waterMl
        self.gels = gels
        self.gelType = gelType
        self.bars = bars
        self.barType = barType
        self.perceivedExertionRating = perceivedExertionRating
        self.notes = notes
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case dateCreated = "date_created"
        case activityRefId = "activity_ref_id"
        case waterMl = "water_ml"
        case gels = "gels"
        case gelType = "gel_type"
        case bars = "bars"
        case barType = "bar_type"
        case perceivedExertionRating = "perceived_exertion"
        case notes = "notes"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.activityRefId = try container.decodeIfPresent(String.self, forKey: .activityRefId)
        self.waterMl = try container.decodeIfPresent(Int.self, forKey: .waterMl)
        self.gels = try container.decodeIfPresent(Double.self, forKey: .gels)
        self.gelType = try container.decodeIfPresent(String.self, forKey: .gelType)
        self.bars = try container.decodeIfPresent(Double.self, forKey: .bars)
        self.barType = try container.decodeIfPresent(String.self, forKey: .barType)
        self.perceivedExertionRating = try container.decodeIfPresent(Int.self, forKey: .perceivedExertionRating)
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.activityRefId, forKey: .activityRefId)
        try container.encodeIfPresent(waterMl, forKey: .waterMl)
        try container.encodeIfPresent(gels, forKey: .gels)
        try container.encodeIfPresent(gelType, forKey: .gelType)
        try container.encodeIfPresent(bars, forKey: .bars)
        try container.encodeIfPresent(barType, forKey: .barType)
        try container.encodeIfPresent(perceivedExertionRating, forKey: .perceivedExertionRating)
        try container.encodeIfPresent(notes, forKey: .notes)
    }
}


final class AllActivityManager {
    
    static let shared = AllActivityManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    
    private func userDocument(userID: String) -> DocumentReference {
        userCollection.document(userID)
    }
    
    /// User activities sub-collection ref
    private func userActivitiesCollection(userId: String) -> CollectionReference {
        userDocument(userID: userId).collection("activities")
    }
    
    /// User activity Doc ref
    private func userActivitiesDocument(userId: String, activityId: String) -> DocumentReference {
        userActivitiesCollection(userId: userId).document(activityId)
    }
    
    private func userActivityNutritionCollection(userId: String) -> CollectionReference {
        userDocument(userID: userId).collection("active_nutrition")
    }
    
    private func userActivityNutritionDocument(userId: String, activityId: String) -> DocumentReference {
        userActivityNutritionCollection(userId: userId).document(activityId)
    }
    
    
    
    // MARK: Functions --
    
    /// add specified nutrition info
    func createUserActivityNutritionDocument(userId: String, activityId: String, waterMl: Int, gels: Double, gelType: String, bars: Double, barType: String, perceivedExertionRating: Int, notes: String) async throws {
        
        let documentId = activityId
        
        let postData: [String:Any] = [
            UserActivityMetaData.CodingKeys.id.rawValue : documentId,
            UserActivityMetaData.CodingKeys.dateCreated.rawValue : Date(),
            UserActivityMetaData.CodingKeys.waterMl.rawValue : waterMl,
            UserActivityMetaData.CodingKeys.gels.rawValue : gels,
            UserActivityMetaData.CodingKeys.gelType.rawValue : gelType,
            UserActivityMetaData.CodingKeys.bars.rawValue : bars,
            UserActivityMetaData.CodingKeys.barType.rawValue : barType,
            UserActivityMetaData.CodingKeys.perceivedExertionRating.rawValue : perceivedExertionRating,
            UserActivityMetaData.CodingKeys.notes.rawValue : notes
        ]
        try await userActivityNutritionDocument(userId: userId, activityId: activityId).setData(postData, merge: false)
    }
    
 
    /// Fetch specified nutrition info
    func fetchUserActivityNutritionDocument(userId: String, activityId: String) async throws -> UserActivityMetaData {
        try await userActivityNutritionDocument(userId: userId, activityId: activityId).getDocument(as: UserActivityMetaData.self)
    }
  
    
//    func fetchUserActivitiesWithPagination(userId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (itemsArray: [UserActivity], lastDocument: DocumentSnapshot?) {
//        
//        let descendingBool: Bool = false
//        
//        if let lastDocument {
//            return try await userActivitiesCollection(userId: userId)
//                .order(by: UserActivity.CodingKeys.startDate.rawValue, descending: descendingBool)
//                .limit(to: count)
//                .start(afterDocument: lastDocument)
//                .getDocumentsWithSnapshot(as: UserActivity.self)
//        } else {
//            return try await userActivitiesCollection(userId: userId)
//                .order(by: UserActivity.CodingKeys.startDate.rawValue, descending: descendingBool)
//                .limit(to: count)
//                .getDocumentsWithSnapshot(as: UserActivity.self)
//        }
//    }
    
}
