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
    
    func connect() {
        StravaAuthManager.shared.authorize { [weak self] success in
            DispatchQueue.main.async {
                self?.isConnected = success
                if success {
                    Task { await self?.fetchAthleteProfile() }
                } else {
                    self?.errorMessage = "Failed to connect to Strava."
                }
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
    
    func refreshTokenIfNeeded() async {
        let token = StravaAuthManager.shared.accessToken
        let expiration = StravaAuthManager.shared.tokenExpiration
        
        if token == nil || (expiration != nil && Date() >= expiration!) {
            await withCheckedContinuation { continuation in
                StravaAuthManager.shared.refreshAccessToken { success in
                    continuation.resume()
                }
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


