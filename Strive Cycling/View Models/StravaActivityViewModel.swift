//
//  StravaActivityViewModel.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/20/25.
//

import Foundation
import Combine

@MainActor
final class StravaActivityViewModel: ObservableObject {
    @Published var activities: [StravaActivity] = []
  //  @Published var activitiesCount: Int?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchRecentActivities() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let activities = try await StravaActivityManager.shared.fetchRecentActivitiesAsync()
                self.activities = activities
    //            self.activitiesCount = activities.count
            } catch {
                self.errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
