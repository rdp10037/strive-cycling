//
//  StravaAuthViewModel.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/20/25.
//

import Foundation

@MainActor
final class StravaAuthViewModel: ObservableObject {
    
    @Published var isConnected = false
    @Published var errorMessage: String?

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
                if !success {
                    self?.errorMessage = "Failed to connect to Strava."
                }
            }
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

    func disconnect() {
        StravaAuthManager.shared.disconnect()
        isConnected = false
    }

    var token: String? {
        StravaAuthManager.shared.accessToken
    }
}

