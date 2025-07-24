//
//  UserActivityViewModel.swift
//  Strive Cycling
//
//  Created by Rob Pee on 7/24/25.
//

import Foundation
import FirebaseFirestore

@MainActor
final class UserActivityViewModel: ObservableObject {
    
    
    func addActivityNutritionData(activityId: String, waterMl: Int, gels: Double, gelType: String, bars: Double, barType: String, perceivedExertionRating: Int, notes: String) {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try await AllActivityManager.shared.createUserActivityNutritionDocument(userId: authDataResult.uid, activityId: activityId, waterMl: waterMl, gels: gels, gelType: gelType, bars: bars, barType: barType, perceivedExertionRating: perceivedExertionRating, notes: notes)
        }
    }
    
    
    @Published private var selectedActivityNutritionData: UserActivityMetaData? = nil
    func fetchSpecificActivityNutritionData(activityId: String) async {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            let activityNutritionData = try await AllActivityManager.shared.fetchUserActivityNutritionDocument(userId: authDataResult.uid, activityId: activityId)
            self.selectedActivityNutritionData = activityNutritionData
        } catch {
            print("No nutrition data found for this activityId: \(activityId)")
        }
    }
    
    
//    @Published private(set) var userActivities: [UserActivity] = []
//    private var userActivitiesLastDocument: DocumentSnapshot? = nil
//    
//    func fetchUserActivitiesWithPagination(userId: String) {
//        Task {
//            let (userActivities, lastDocument) = try await AllActivityManager.shared.fetchUserActivitiesWithPagination(userId: userId, count: 10, lastDocument: userActivitiesLastDocument)
//            
//            self.userActivities.append(contentsOf: userActivities)
//            if let lastDocument {
//                self.userActivitiesLastDocument = lastDocument
//            }
//        }
//    }
    
}
