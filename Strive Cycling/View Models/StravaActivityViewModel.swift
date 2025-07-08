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
    @Published var selectedDetailedActivity: StravaDetailedActivity?
    
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
    func fetchRecentActivities() async {
        isLoading = true
        errorMessage = nil
      
            do {
                let activities = try await StravaActivityManager.shared.fetchRecentActivitiesWithCount(count: 10)
                self.activities = activities
            } catch {
                self.errorMessage = error.localizedDescription
            }
            isLoading = false
    }
    
    /// Loads the detailed activity object for the given Strava activity ID.
    ///
    /// This method fetches a full detailed activity from the `/activities/{id}`
    /// Strava API endpoint. It updates the `selectedDetailedActivity` property
    /// upon success, and sets the `errorMessage` property if the fetch fails.
    ///
    /// The method also manages the `isLoading` flag to reflect loading state
    /// during the async operation.
    ///
    /// - Parameter activityId: The Strava activity ID to fetch in detail.
    /// - Note: This method should be called from the main actor context.
    func loadDetailedActivity(for activityId: Int) async {
        isLoading = true
        errorMessage = nil
       
            do {
                let detailed = try await StravaActivityManager.shared.fetchDetailedActivity(by: activityId)
                self.selectedDetailedActivity = detailed
            } catch {
                self.errorMessage = error.localizedDescription
            }
            isLoading = false
        
    }
    
}
