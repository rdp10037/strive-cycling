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

    func fetchRecentActivities() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let activities = try await StravaActivityManager.shared.fetchRecentActivitiesAsync(count: 10)
                self.activities = activities
            } catch {
                self.errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
