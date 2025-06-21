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
    
    func authorize(completion: @escaping (Bool) -> Void) {
        guard let url = getAuthorizationURL() else {
            completion(false)
            return
        }
        
        let scheme = "strive"
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: scheme) { callbackURL, error in
            guard let callbackURL = callbackURL,
                  let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "code" })?.value else {
                completion(false)
                return
            }
            
            self.exchangeCodeForToken(code: code, completion: completion)
        }
        
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
    }
    
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
    
    private func exchangeCodeForToken(code: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: tokenURL) else {
            completion(false)
            return
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
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let accessToken = json["access_token"] as? String,
                  let refreshToken = json["refresh_token"] as? String,
                  let expiresAt = json["expires_at"] as? TimeInterval else {
                completion(false)
                return
            }
            
            KeychainHelper.shared.save(key: self.tokenKey, value: accessToken)
            KeychainHelper.shared.save(key: self.refreshKey, value: refreshToken)
            KeychainHelper.shared.save(key: self.expiryKey, value: String(expiresAt))
            
            completion(true)
        }.resume()
    }
    
    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = self.refreshToken,
              let url = URL(string: tokenURL) else {
            completion(false)
            return
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
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let newAccessToken = json["access_token"] as? String,
                  let newRefreshToken = json["refresh_token"] as? String,
                  let newExpiresAt = json["expires_at"] as? TimeInterval else {
                completion(false)
                return
            }
            
            KeychainHelper.shared.save(key: self.tokenKey, value: newAccessToken)
            KeychainHelper.shared.save(key: self.refreshKey, value: newRefreshToken)
            KeychainHelper.shared.save(key: self.expiryKey, value: String(newExpiresAt))
            
            completion(true)
        }.resume()
    }
    
    func fetchAthleteProfile() async throws -> StravaAthlete {
        guard let token = accessToken else {
            throw URLError(.userAuthenticationRequired)
        }
        
        var request = URLRequest(url: URL(string: "https://www.strava.com/api/v3/athlete")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let athlete = try JSONDecoder().decode(StravaAthlete.self, from: data)
        return athlete
    }
    
    func fetchAthleteStats(athleteId: Int) async throws -> StravaStats {
        guard let accessToken = self.accessToken else {
            throw URLError(.userAuthenticationRequired)
        }
        
        var request = URLRequest(url: URL(string: "https://www.strava.com/api/v3/athletes/\(athleteId)/stats")!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug: Print full raw JSON response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Strava Stats JSON Response:\n\(jsonString)")
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
