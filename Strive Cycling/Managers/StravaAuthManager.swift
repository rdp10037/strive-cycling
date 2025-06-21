//
//  StravaAuthManager.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/19/25.
//

import Foundation
import SwiftUI
import AuthenticationServices

// MARK: - Documentation References
/// ASWebAuthenticationPresentationContextProviding:    https://developer.apple.com/documentation/authenticationservices/aswebauthenticationpresentationcontextproviding
/// ASWebAuthenticationSession:      https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession
/// Strava OAuth 2.0:    https://developers.strava.com/docs/authentication/
/// Strava Token Exchange:    https://developers.strava.com/docs/authentication/#tokenexchange
/// Refreshing Expired Tokens:       https://developers.strava.com/docs/authentication/#refreshingexpiredaccesstokens
/// PresentationAnchor:      https://developer.apple.com/documentation/authenticationservices/aswebauthenticationpresentationcontextproviding/presentationanchor(for:)

import UIKit

final class StravaAuthManager: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = StravaAuthManager()
    
    /// Reference clientID and clientSecret from associated secrets.xcconfig + info.plist keys. For local testing connivance, set the values directly here.
    private let clientID = Bundle.main.object(forInfoDictionaryKey: "STRAVA_CLIENT_ID") as? String ?? ""
    private let clientSecret = Bundle.main.object(forInfoDictionaryKey: "STRAVA_CLIENT_SECRET") as? String ?? ""
    private let redirectURI = "https://rdp10037.github.io/strive-cycling/strava-redirect.html"
    private let tokenURL = "https://www.strava.com/oauth/token"
    private let authURL = "https://www.strava.com/oauth/authorize"
    private let scope = "activity:read_all"
    
    private let tokenKey = "strava_access_token"
    private let refreshKey = "strava_refresh_token"
    private let expiryKey = "strava_token_expiration"
    
    var accessToken: String? {
        KeychainHelper.shared.read(key: tokenKey)
    }
    
    var refreshToken: String? {
        KeychainHelper.shared.read(key: refreshKey)
    }
    
    var tokenExpiration: Date? {
        if let timestamp = KeychainHelper.shared.read(key: expiryKey),
           let timeInterval = TimeInterval(timestamp) {
            return Date(timeIntervalSince1970: timeInterval)
        }
        return nil
    }
    
    
    @MainActor
    /// Begins the Strava OAuth2 authentication flow using `ASWebAuthenticationSession`.
    ///
    /// This function:
    /// - Opens a web session for the user to authenticate via Strava.
    /// - Handles the redirect callback and extracts the authorization code.
    /// - Exchanges the code for an access token using `exchangeCodeForToken(code:)`.
    /// - Returns a Boolean indicating success or failure.
    ///
    /// The session uses a custom URL scheme (`strive://`) to intercept the callback.
    ///
    /// - Returns: `true` if authentication and token exchange succeeded, otherwise `false`.
    func authorize() async -> Bool {
        guard let authURL = getAuthorizationURL() else {
            print("Invalid authorization URL")
            return false
        }

        let scheme = "strive"

        return await withCheckedContinuation { continuation in
            let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme) { callbackURL, error in
                if let callbackURL,
                   let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                       .queryItems?.first(where: { $0.name == "code" })?.value {
                    
                    Task {
                        let success = await self.exchangeCodeForToken(code: code)
                        continuation.resume(returning: success)
                    }
                } else {
                    print("Authorization failed or was cancelled.")
                    continuation.resume(returning: false)
                }
            }

            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true
            session.start()
        }
    }


    
    /// Constructs the URL used to initiate the Strava OAuth2 authorization flow.
    ///
    /// This URL includes all necessary query parameters such as client ID, redirect URI,
    /// response type, requested scope, and approval prompt settings. The resulting URL
    /// is used to open an `ASWebAuthenticationSession` and prompt the user to log in.
    ///
    /// - Returns: A fully constructed `URL` pointing to Strava's OAuth authorization endpoint, or `nil` if the URL is invalid.
    private func getAuthorizationURL() -> URL? {
        var components = URLComponents(string: authURL)
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "approval_prompt", value: "auto")
        ]
        return components?.url
    }

    
    
    /// Exchanges an authorization code for Strava access and refresh tokens.
    ///
    /// This function sends a `POST` request to the Strava token endpoint using the provided
    /// authorization code, along with the `client_id` and `client_secret` stored in the app's
    /// `Info.plist`. Upon success, it stores the retrieved `access_token`, `refresh_token`,
    /// and `expires_at` timestamp securely in the keychain.
    ///
    /// This function is used internally after the user successfully authenticates via the
    /// `authorize()` flow.
    ///
    /// - Parameter code: The authorization code returned by Strava after user login.
    /// - Returns: `true` if token exchange succeeded and tokens were stored, otherwise `false`.
    func exchangeCodeForToken(code: String) async -> Bool {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "STRAVA_CLIENT_ID") as? String,
              let clientSecret = Bundle.main.object(forInfoDictionaryKey: "STRAVA_CLIENT_SECRET") as? String else {
            return false
        }

        let tokenURL = "https://www.strava.com/oauth/token"
        guard let url = URL(string: tokenURL) else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let params = [
            "client_id": clientID,
            "client_secret": clientSecret,
            "code": code,
            "grant_type": "authorization_code"
        ]

        request.httpBody = params
            .compactMap { "\($0)=\($1)" }
            .joined(separator: "&")
            .data(using: .utf8)

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let accessToken = json["access_token"] as? String,
                  let refreshToken = json["refresh_token"] as? String,
                  let expiresAt = json["expires_at"] as? TimeInterval else {
                return false
            }

            KeychainHelper.shared.save(key: tokenKey, value: accessToken)
            KeychainHelper.shared.save(key: refreshKey, value: refreshToken)
            KeychainHelper.shared.save(key: expiryKey, value: String(expiresAt))

            return true
        } catch {
            print("Token exchange failed: \(error.localizedDescription)")
            return false
        }
    }

    
    /// Refreshes the current access token using the saved refresh token.
    ///
    /// This method sends a `POST` request to the Strava token endpoint to obtain
    /// a new `access_token`, `refresh_token`, and `expires_at` using the existing refresh token.
    ///
    /// Tokens are securely stored using `KeychainHelper`.
    ///
    /// - Returns: `true` if the refresh was successful and tokens were updated; otherwise `false`.
    func refreshAccessToken() async -> Bool {
        guard let refreshToken = self.refreshToken,
              let url = URL(string: tokenURL) else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let params = [
            "client_id": clientID,
            "client_secret": clientSecret,
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]

        request.httpBody = params
            .compactMap { "\($0)=\($1)" }
            .joined(separator: "&")
            .data(using: .utf8)

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let newAccessToken = json["access_token"] as? String,
                  let newRefreshToken = json["refresh_token"] as? String,
                  let newExpiresAt = json["expires_at"] as? TimeInterval else {
                return false
            }

            KeychainHelper.shared.save(key: self.tokenKey, value: newAccessToken)
            KeychainHelper.shared.save(key: self.refreshKey, value: newRefreshToken)
            KeychainHelper.shared.save(key: self.expiryKey, value: String(newExpiresAt))

            return true
        } catch {
            print("Failed to refresh token: \(error.localizedDescription)")
            return false
        }
    }
    
    
    /// Fetches the authenticated athlete's profile from the Strava API.
    ///
    /// This method uses the current access token to query Strava's `/athlete` endpoint
    /// and decodes the response into a `StravaAthlete` model.
    ///
    /// - Returns: A `StravaAthlete` object representing the authenticated user.
    /// - Throws: An error if authentication is missing or the network request fails.
    func fetchAthleteProfile() async throws -> StravaAthlete {
        guard let token = accessToken else {
            throw URLError(.userAuthenticationRequired)
        }

        guard let url = URL(string: "https://www.strava.com/api/v3/athlete") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let athlete = try JSONDecoder().decode(StravaAthlete.self, from: data)
        return athlete
    }

    
    /// Fetches year-to-date and lifetime statistics for the authenticated athlete.
    ///
    /// This method queries Strava's `/athletes/{id}/stats` endpoint using the athlete's ID.
    /// It returns a `StravaStats` object containing totals for rides, runs, and swims.
    ///
    /// - Parameter athleteId: The Strava athlete ID used to retrieve stats.
    /// - Returns: A `StravaStats` model containing various lifetime and recent activity totals.
    /// - Throws: An error if the user is not authenticated or if the network or decoding fails.
    func fetchAthleteStats(athleteId: Int) async throws -> StravaStats {
        guard let accessToken = self.accessToken else {
            throw URLError(.userAuthenticationRequired)
        }

        guard let url = URL(string: "https://www.strava.com/api/v3/athletes/\(athleteId)/stats") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(StravaStats.self, from: data)
    }

    
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
    
    
    func disconnect() {
        KeychainHelper.shared.delete(key: tokenKey)
        KeychainHelper.shared.delete(key: refreshKey)
        KeychainHelper.shared.delete(key: expiryKey)
    }
}



struct StravaTokenResponse: Codable {
    let access_token: String
    let refresh_token: String
    let expires_in: Int
}



struct StravaStats: Codable {
    let biggestRideDistance: Double?
    let biggestClimbElevationGain: Double?
    
    let recentRideTotals: StravaActivityTotals?
    let recentRunTotals: StravaActivityTotals?
    let recentSwimTotals: StravaActivityTotals?
    
    let ytdRideTotals: StravaActivityTotals?
    let ytdRunTotals: StravaActivityTotals?
    let ytdSwimTotals: StravaActivityTotals?
    
    let allRideTotals: StravaActivityTotals?
    let allRunTotals: StravaActivityTotals?
    let allSwimTotals: StravaActivityTotals?
}

struct StravaActivityTotals: Codable {
    let count: Int
    let distance: Double
    let movingTime: Int
    let elevationGain: Double
    let achievementCount: Int?
}
