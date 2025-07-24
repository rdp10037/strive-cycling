//
//  AuthenticationManager.swift
//  Strive Cycling
//
//  Created by Rob Pee on 7/23/25.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import GoogleSignIn

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

protocol AuthenticationTermsConditionsProtocol {
    var termsIsValid: Bool { get }
}

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    let displayName: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.displayName = user.displayName
    }
}

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager {

    static let shared = AuthenticationManager()
    private init() {}
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        print("Providers: \(providers)")
        return providers
    }
    
   
    func signOut() throws {
        try Auth.auth().signOut()
        
    }
    
    // MARK: - Delete Account
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotAuthenticated
        }
        
        try await user.delete()
    }
    
    // MARK: - Re-authenticate User
    func reauthenticateUser(password: String? = nil) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotAuthenticated
        }

        // Identify the user's sign-in method
        let providerID = user.providerData.first?.providerID

        switch providerID {
        case "password":
            guard let email = user.email, let password else {
                throw AuthError.unknownError
            }
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            try await user.reauthenticate(with: credential)

        case "apple.com":
            try await signInAppleForReauth()
        case "google.com":
            try await signInGoogleForReauth()
        default:
            throw AuthError.unknownError
        }
    }

    // MARK: - Reuse Sign-in Logic for Reauthentication
    private func signInAppleForReauth() async throws {
        let tokens = try await SignInAppleHelper().startSignInWithAppleFlow()
        _ = try await signInWithApple(tokens: tokens)
    }

    private func signInGoogleForReauth() async throws {
        let tokens = try await SignInGoogleHelper().signIn()
        _ = try await signInWithGoogle(tokens: tokens)
    }


}

enum AuthError: Error {
    case userNotAuthenticated
    case invalidCredential
    case weakPassword
    case incorrectPassword
    case requiresRecentLogin
    case emailAlreadyInUse
    case invalidEmail
    case networkError
    case unknownError
}


// MARK:    SIGN IN EMAIL
extension AuthenticationManager {
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        do {
            let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
            return AuthDataResultModel(user: authDataResult.user)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
    /// Map Firebase error codes to custom AuthError cases
    private func mapFirebaseError(_ error: NSError) -> AuthError {
        guard let errorCode = AuthErrorCode(rawValue: error.code) else {
            return .unknownError
        }

        switch errorCode {
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .invalidEmail:
            return .invalidEmail
        case .weakPassword:
            return .weakPassword
        case .wrongPassword:
            return .incorrectPassword
        case .requiresRecentLogin:
            return .requiresRecentLogin
        case .networkError:
            return .networkError
        default:
            return .unknownError
        }
    }
}

 

// MARK:    SIGN IN SSO
extension AuthenticationManager {
    
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signInWithCredential(credential: credential)
    }
    
    @discardableResult
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(providerID: .apple, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await signInWithCredential(credential: credential)
    }

    func signInWithCredential(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
