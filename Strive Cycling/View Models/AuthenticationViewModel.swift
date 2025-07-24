//
//  AuthenticationViewModel.swift
//  Strive Cycling
//
//  Created by Rob Pee on 7/23/25.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    @Published var signUpAppleValid: Bool = false
    
    @Published var appleAuthFirstName: String = ""
    @Published var appleAuthLastName: String = ""
    
    let signInAppleHelper = SignInAppleHelper()
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        
        let user = try await UserManager.shared.userExists(userID: authDataResult.uid)
        
        if user == false {
            print("running create func")
            let user = DBUser(auth: authDataResult)
            try await UserManager.shared.createNewUser(user: user)
        } else {
            print(user)
        }
    }
    
    func signInApple() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        
        self.appleAuthFirstName = tokens.firstName ?? ""
        self.appleAuthLastName = tokens.lastName ?? ""
        
        let authDataResult = try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
        
        let user = try await UserManager.shared.userExists(userID: authDataResult.uid)
        
        if user == false {
            let user = DBUser(auth: authDataResult)
            try await UserManager.shared.createNewUser(user: user)
            signUpAppleValid = true
        } else {
            signUpAppleValid = true
        }
    }
}
