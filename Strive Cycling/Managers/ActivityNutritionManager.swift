//
//  ActivityNutritionManager.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/19/25.
//

import Foundation

struct ActivityNutrition: Codable, Identifiable {
    let id: Int
    var waterMl: Int?
    var gels: Double?
    var gelType: String?
    var bars: Double?
    var barType: String?
    var perceivedExertionRating: Int?
    var notes: String?
}
