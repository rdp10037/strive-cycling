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
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// Fetches the most recent Strava activities and updates the view model state.
    ///
    /// This function initiates an asynchronous task to retrieve the latest activities (up to a specified count)
    /// using `StravaActivityManager.fetchRecentActivitiesWithCount(count:)`.
    ///
    /// While the task is in progress, it sets `isLoading` to `true`. Once complete, it:
    /// - Updates the `activities` property on success
    /// - Sets an `errorMessage` on failure
    /// - Resets `isLoading` to `false`
    ///
    /// This method is called when the dashboard or activity feed is loaded or refreshed.
    func fetchRecentActivities() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let activities = try await StravaActivityManager.shared.fetchRecentActivitiesWithCount(count: 10)
                self.activities = activities
            } catch {
                self.errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    /// Clears the current list of activities and resets related state.
    ///
    /// This is typically called when a user disconnects their Strava account,
    /// ensuring that previously fetched data is removed from the UI.
//    func clearActivities() {
//        Task {
//            print("Clear Activities was called")
//            activities = []
//            errorMessage = nil
//            isLoading = false
//        }
//    }
 
}
