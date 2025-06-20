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



//final class StravaAuthManager: NSObject {
//    static let shared = StravaAuthManager()
//
//    // MARK: - Private Constants
//    private let clientID: String = Bundle.main.object(forInfoDictionaryKey: "STRAVA_CLIENT_ID") as? String ?? ""
//    private let clientSecret: String = Bundle.main.object(forInfoDictionaryKey: "STRAVA_CLIENT_SECRET") as? String ?? ""
//    private let redirectURI = "https://rdp10037.github.io/strive-cycling/strava-redirect.html"
//
//    private let authorizationEndpoint = "https://www.strava.com/oauth/authorize"
//    private let tokenEndpoint = "https://www.strava.com/oauth/token"
//    private let scope = "activity:read_all"
//
//    // MARK: - Session and Token
//    private var authSession: ASWebAuthenticationSession?
//    private(set) var accessToken: String?
//    private(set) var refreshToken: String?
//    private(set) var tokenExpiration: Date?
//
//    // MARK: - Auth Flow
//    func authorize(completion: @escaping (Bool) -> Void) {
//        guard let authURL = getAuthorizationURL() else {
//            print("❌ Failed to build auth URL")
//            completion(false)
//            return
//        }
//
//        let callbackScheme = URL(string: redirectURI)?.scheme
//
//        authSession = ASWebAuthenticationSession(
//            url: authURL,
//            callbackURLScheme: callbackScheme
//        ) { callbackURL, error in
//            guard
//                error == nil,
//                let callbackURL = callbackURL,
//                let queryItems = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?.queryItems,
//                let code = queryItems.first(where: { $0.name == "code" })?.value
//            else {
//                print("❌ Auth session error or code missing")
//                completion(false)
//                return
//            }
//
//            self.exchangeCodeForToken(code: code, completion: completion)
//        }
//
//        authSession?.presentationContextProvider = self
//        authSession?.prefersEphemeralWebBrowserSession = true
//        authSession?.start()
//    }
//
//    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
//        guard let refreshToken = refreshToken else {
//            completion(false)
//            return
//        }
//
//        var request = URLRequest(url: URL(string: tokenEndpoint)!)
//        request.httpMethod = "POST"
//
//        let params = [
//            "client_id": clientID,
//            "client_secret": clientSecret,
//            "grant_type": "refresh_token",
//            "refresh_token": refreshToken
//        ]
//
//        request.httpBody = params
//            .compactMap { "\($0)=\($1)" }
//            .joined(separator: "&")
//            .data(using: .utf8)
//
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//        URLSession.shared.dataTask(with: request) { data, _, _ in
//            guard
//                let data = data,
//                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                let accessToken = json["access_token"] as? String,
//                let refreshToken = json["refresh_token"] as? String,
//                let expiresAt = json["expires_at"] as? TimeInterval
//            else {
//                completion(false)
//                return
//            }
//
//            self.accessToken = accessToken
//            self.refreshToken = refreshToken
//            self.tokenExpiration = Date(timeIntervalSince1970: expiresAt)
//            completion(true)
//        }.resume()
//    }
//
//    private func getAuthorizationURL() -> URL? {
//        var components = URLComponents(string: authorizationEndpoint)
//        components?.queryItems = [
//            URLQueryItem(name: "client_id", value: clientID),
//            URLQueryItem(name: "redirect_uri", value: redirectURI),
//            URLQueryItem(name: "response_type", value: "code"),
//            URLQueryItem(name: "scope", value: scope),
//            URLQueryItem(name: "approval_prompt", value: "auto")
//        ]
//        return components?.url
//    }
//
//    private func exchangeCodeForToken(code: String, completion: @escaping (Bool) -> Void) {
//        guard let url = URL(string: tokenEndpoint) else {
//            completion(false)
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let params = [
//            "client_id": clientID,
//            "client_secret": clientSecret,
//            "code": code,
//            "grant_type": "authorization_code"
//        ]
//
//        request.httpBody = params
//            .compactMap { "\($0)=\($1)" }
//            .joined(separator: "&")
//            .data(using: .utf8)
//
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//        URLSession.shared.dataTask(with: request) { data, _, _ in
//            guard
//                let data = data,
//                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                let accessToken = json["access_token"] as? String,
//                let refreshToken = json["refresh_token"] as? String,
//                let expiresAt = json["expires_at"] as? TimeInterval
//            else {
//                completion(false)
//                return
//            }
//
//            self.accessToken = accessToken
//            self.refreshToken = refreshToken
//            self.tokenExpiration = Date(timeIntervalSince1970: expiresAt)
//            completion(true)
//        }.resume()
//    }
//    
//    func disconnect() {
//        accessToken = nil
//        refreshToken = nil
//        tokenExpiration = nil
//
//        UserDefaults.standard.removeObject(forKey: "strava_access_token")
//        UserDefaults.standard.removeObject(forKey: "strava_refresh_token")
//        UserDefaults.standard.removeObject(forKey: "strava_token_expiration")
//    }
//    
//
//}
//
//extension StravaAuthManager: ASWebAuthenticationPresentationContextProviding {
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
//    }
//    
//}




//final class StravaAuthManager: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
//    static let shared = StravaAuthManager()
//
//    // MARK: - Info.plist Constants
//    private let clientID: String = Bundle.main.object(forInfoDictionaryKey: "STRAVA_CLIENT_ID") as? String ?? ""
//    private let clientSecret: String = Bundle.main.object(forInfoDictionaryKey: "STRAVA_CLIENT_SECRET") as? String ?? ""
//    private let redirectURI = "https://rdp10037.github.io/strive-cycling/strava-redirect.html"
//
//    private let authorizationEndpoint = "https://www.strava.com/oauth/authorize"
//    private let tokenEndpoint = "https://www.strava.com/oauth/token"
//    private let scope = "activity:read_all"
//
//    // MARK: - Temp Token Storage
//    @AppStorage("stravaAccessToken") private(set) var accessToken: String?
//    @AppStorage("stravaRefreshToken") private(set) var refreshToken: String?
//    @AppStorage("stravaTokenExpiration") private(set) var tokenExpirationTimestamp: Double = 0
//
//    var tokenExpiration: Date? {
//        get { Date(timeIntervalSince1970: tokenExpirationTimestamp) }
//        set { tokenExpirationTimestamp = newValue?.timeIntervalSince1970 ?? 0 }
//    }
//
//    // MARK: - Authorization URL
//    func getAuthorizationURL() -> URL? {
//        var components = URLComponents(string: authorizationEndpoint)
//        components?.queryItems = [
//            URLQueryItem(name: "client_id", value: clientID),
//            URLQueryItem(name: "redirect_uri", value: redirectURI),
//            URLQueryItem(name: "response_type", value: "code"),
//            URLQueryItem(name: "scope", value: scope),
//            URLQueryItem(name: "approval_prompt", value: "auto")
//        ]
//        return components?.url
//    }
//
//    // MARK: - Start OAuth Flow
//    func authorize() {
//        guard let authURL = getAuthorizationURL() else {
//            print("Failed to build auth URL")
//            return
//        }
//
//        let session = ASWebAuthenticationSession(
//            url: authURL,
//            callbackURLScheme: "strive"
//        ) { callbackURL, error in
//            self.handleAuthCallback(callbackURL: callbackURL, error: error)
//        }
//
//        session.presentationContextProvider = self
//        session.prefersEphemeralWebBrowserSession = true
//        session.start()
//    }
//
//    // MARK: - Handle Auth Callback
//    func handleAuthCallback(callbackURL: URL?, error: Error?) {
//        guard error == nil,
//              let url = callbackURL,
//              let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
//              let code = queryItems.first(where: { $0.name == "code" })?.value else {
//            print("Auth callback error")
//            return
//        }
//
//        exchangeCodeForToken(code: code) { success in
//            print(success ? "Token exchange successful" : "Token exchange failed")
//        }
//    }
//
//    // MARK: - Exchange Code for Token
//    private func exchangeCodeForToken(code: String, completion: @escaping (Bool) -> Void) {
//        guard let url = URL(string: tokenEndpoint) else {
//            completion(false)
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let params = [
//            "client_id": clientID,
//            "client_secret": clientSecret,
//            "code": code,
//            "grant_type": "authorization_code"
//        ]
//
//        request.httpBody = params.map { "\($0)=\($1)" }.joined(separator: "&").data(using: .utf8)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard
//                let data = data,
//                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                let accessToken = json["access_token"] as? String,
//                let refreshToken = json["refresh_token"] as? String,
//                let expiresAt = json["expires_at"] as? TimeInterval
//            else {
//                completion(false)
//                return
//            }
//
//            DispatchQueue.main.async {
//                self.accessToken = accessToken
//                self.refreshToken = refreshToken
//                self.tokenExpiration = Date(timeIntervalSince1970: expiresAt)
//                completion(true)
//            }
//        }.resume()
//    }
//
//    // MARK: - Refresh Token
//    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
//        guard let refreshToken = refreshToken,
//              let url = URL(string: tokenEndpoint) else {
//            completion(false)
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let params = [
//            "client_id": clientID,
//            "client_secret": clientSecret,
//            "grant_type": "refresh_token",
//            "refresh_token": refreshToken
//        ]
//
//        request.httpBody = params.map { "\($0)=\($1)" }.joined(separator: "&").data(using: .utf8)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard
//                let data = data,
//                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                let accessToken = json["access_token"] as? String,
//                let newRefreshToken = json["refresh_token"] as? String,
//                let expiresAt = json["expires_at"] as? TimeInterval
//            else {
//                completion(false)
//                return
//            }
//
//            DispatchQueue.main.async {
//                self.accessToken = accessToken
//                self.refreshToken = newRefreshToken
//                self.tokenExpiration = Date(timeIntervalSince1970: expiresAt)
//                completion(true)
//            }
//        }.resume()
//    }
//
//    // MARK: - Presentation Anchor
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//        UIApplication.shared.connectedScenes
//            .compactMap { $0 as? UIWindowScene }
//            .flatMap { $0.windows }
//            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
//    }
//}




struct StravaTokenResponse: Codable {
    let access_token: String
    let refresh_token: String
    let expires_in: Int
}

