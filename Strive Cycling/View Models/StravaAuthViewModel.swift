//
//  StravaAuthViewModel.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/20/25.
//

//import Foundation
//
//@MainActor
//final class StravaAuthViewModel: ObservableObject {
//
//    @Published var isConnected = false
//    @Published var errorMessage: String?
//
//    var isAuthorized: Bool {
//        guard let token = StravaAuthManager.shared.accessToken,
//              let expiration = StravaAuthManager.shared.tokenExpiration
//        else {
//            return false
//        }
//        return Date() < expiration
//    }
//
//    func connect() {
//        StravaAuthManager.shared.authorize { [weak self] success in
//            DispatchQueue.main.async {
//                self?.isConnected = success
//                if !success {
//                    self?.errorMessage = "Failed to connect to Strava."
//                }
//            }
//        }
//    }
//
//    func refreshTokenIfNeeded() async {
//        let token = StravaAuthManager.shared.accessToken
//        let expiration = StravaAuthManager.shared.tokenExpiration
//
//        if token == nil || (expiration != nil && Date() >= expiration!) {
//            await withCheckedContinuation { continuation in
//                StravaAuthManager.shared.refreshAccessToken { success in
//                    continuation.resume()
//                }
//            }
//        }
//    }
//
//    func disconnect() {
//        StravaAuthManager.shared.disconnect()
//        isConnected = false
//    }
//
//    var token: String? {
//        StravaAuthManager.shared.accessToken
//    }
//}


import Foundation

struct StravaAthlete: Codable {
    let id: Int
    let username: String?
    let firstname: String
    let lastname: String
    let profile: String  // This is a URL string
    let city: String?
    let country: String?
    let followerCount: Int?
    let friendCount: Int?
    
    // Computed property for use in views
    var profileURL: URL? {
        URL(string: profile)
    }
    
    var fullName: String {
        "\(firstname) \(lastname)"
    }
    
    var locationText: String {
        [city, country].compactMap { $0 }.joined(separator: ", ")
    }
}


@MainActor
final class StravaAuthViewModel: ObservableObject {
    @Published var isConnected = false
    @Published var errorMessage: String?
    
    @Published var athlete: StravaAthlete?
    @Published var stats: StravaStats?
    
    var isAuthorized: Bool {
        guard let token = StravaAuthManager.shared.accessToken,
              let expiration = StravaAuthManager.shared.tokenExpiration
        else {
            return false
        }
        return Date() < expiration
    }
    
    /// Initiates the Strava OAuth authorization flow and updates the connection state.
    ///
    /// This method performs the following steps:
    /// 1. Calls the async `authorize()` method on `StravaAuthManager`, which presents an `ASWebAuthenticationSession`.
    /// 2. If successful, updates `isConnected` and fetches the authenticated athlete’s profile.
    /// 3. If unsuccessful, sets an appropriate error message for UI display.
    ///
    /// - Note: This function must be called from the main actor context to safely update UI-related properties.
    func connect() {
        Task {
            let success = await StravaAuthManager.shared.authorize()
            self.isConnected = success

            if success {
                await fetchAthleteProfile()
            } else {
                self.errorMessage = "Failed to connect to Strava."
            }
        }
    }
    
    func fetchAthleteProfile() async {
        do {
            let athlete = try await StravaAuthManager.shared.fetchAthleteProfile()
            self.athlete = athlete
            print("Athlete fetched successfully: \(athlete.id)")
            print("Full Athlete Profile: \(athlete)")
        } catch {
            self.errorMessage = "Failed to fetch profile: \(error.localizedDescription)"
        }
    }
    
    /// Refreshes the Strava access token if it is missing or expired.
    /// This ensures API calls are authorized with a valid token.
    ///
    /// If the refresh fails, an error message will be set for UI display.
    func refreshTokenIfNeeded() async {
        let token = StravaAuthManager.shared.accessToken
        let expiration = StravaAuthManager.shared.tokenExpiration

        if token == nil || (expiration != nil && Date() >= expiration!) {
            let success = await StravaAuthManager.shared.refreshAccessToken()
            if !success {
                errorMessage = "Failed to refresh access token. Please try reconnecting to Strava."
            }
        }
    }
    
    
    
    func fetchAthleteStats() async {
        guard let athleteId = athlete?.id else {
            print("Error with Athlete ID in fetchAthleteStats(): Athlete ID is missing.")
            self.errorMessage = "Athlete ID is missing."
            return
        }
        
        do {
            let stats = try await StravaAuthManager.shared.fetchAthleteStats(athleteId: athleteId)
            print("Stats: \(stats)")
            self.stats = stats
        } catch {
            self.errorMessage = "Failed to fetch stats: \(error.localizedDescription)"
        }
    }
    
    
    
    func disconnect() {
        StravaAuthManager.shared.disconnect()
        isConnected = false
        athlete = nil
    }
    
    var token: String? {
        StravaAuthManager.shared.accessToken
    }
}


