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



final class StravaAuthManager: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = StravaAuthManager()

    // MARK: - Info.plist Constants
    private let clientID: String = Bundle.main.object(forInfoDictionaryKey: "STRAVA_CLIENT_ID") as? String ?? ""
    private let clientSecret: String = Bundle.main.object(forInfoDictionaryKey: "STRAVA_CLIENT_SECRET") as? String ?? ""
    private let redirectURI = "https://rdp10037.github.io/strive-cycling/strava-redirect.html"

    private let authorizationEndpoint = "https://www.strava.com/oauth/authorize"
    private let tokenEndpoint = "https://www.strava.com/oauth/token"
    private let scope = "activity:read_all"

    // MARK: - Temp Token Storage
    @AppStorage("stravaAccessToken") private(set) var accessToken: String?
    @AppStorage("stravaRefreshToken") private(set) var refreshToken: String?
    @AppStorage("stravaTokenExpiration") private(set) var tokenExpirationTimestamp: Double = 0

    var tokenExpiration: Date? {
        get { Date(timeIntervalSince1970: tokenExpirationTimestamp) }
        set { tokenExpirationTimestamp = newValue?.timeIntervalSince1970 ?? 0 }
    }

    // MARK: - Authorization URL
    func getAuthorizationURL() -> URL? {
        var components = URLComponents(string: authorizationEndpoint)
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "approval_prompt", value: "auto")
        ]
        return components?.url
    }

    // MARK: - Start OAuth Flow
    func authorize() {
        guard let authURL = getAuthorizationURL() else {
            print("Failed to build auth URL")
            return
        }

        let session = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: "strive"
        ) { callbackURL, error in
            self.handleAuthCallback(callbackURL: callbackURL, error: error)
        }

        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
    }

    // MARK: - Handle Auth Callback
    func handleAuthCallback(callbackURL: URL?, error: Error?) {
        guard error == nil,
              let url = callbackURL,
              let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              let code = queryItems.first(where: { $0.name == "code" })?.value else {
            print("Auth callback error")
            return
        }

        exchangeCodeForToken(code: code) { success in
            print(success ? "Token exchange successful" : "Token exchange failed")
        }
    }

    // MARK: - Exchange Code for Token
    private func exchangeCodeForToken(code: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: tokenEndpoint) else {
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

        request.httpBody = params.map { "\($0)=\($1)" }.joined(separator: "&").data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let accessToken = json["access_token"] as? String,
                let refreshToken = json["refresh_token"] as? String,
                let expiresAt = json["expires_at"] as? TimeInterval
            else {
                completion(false)
                return
            }

            DispatchQueue.main.async {
                self.accessToken = accessToken
                self.refreshToken = refreshToken
                self.tokenExpiration = Date(timeIntervalSince1970: expiresAt)
                completion(true)
            }
        }.resume()
    }

    // MARK: - Refresh Token
    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = refreshToken,
              let url = URL(string: tokenEndpoint) else {
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

        request.httpBody = params.map { "\($0)=\($1)" }.joined(separator: "&").data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let accessToken = json["access_token"] as? String,
                let newRefreshToken = json["refresh_token"] as? String,
                let expiresAt = json["expires_at"] as? TimeInterval
            else {
                completion(false)
                return
            }

            DispatchQueue.main.async {
                self.accessToken = accessToken
                self.refreshToken = newRefreshToken
                self.tokenExpiration = Date(timeIntervalSince1970: expiresAt)
                completion(true)
            }
        }.resume()
    }

    // MARK: - Presentation Anchor
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}




struct StravaTokenResponse: Codable {
    let access_token: String
    let refresh_token: String
    let expires_in: Int
}

