//
//  ProfileViewModel.swift
//  Night Market
//
//  Created by Rob Pee on 7/1/24.
//

import Foundation


@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var userName = ""
    @Published var phoneNumber = ""
    @Published var dateOfBirth = Date()
 
    func loadCurrentUser() {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.getUser(userID: authDataResult.uid)
        }
    }
    
    func updateUserFirstName() {
        guard let user else { return }
        let newValueFirstName = firstName
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try await UserManager.shared.updateUserFirstName(userId: authDataResult.uid, firstName: firstName)
            self.user = try await UserManager.shared.getUser(userID: authDataResult.uid)
        }
    }
    
    func updateUserLastName() {
        guard let user else { return }
        let newValueLastName = lastName
        Task {
            try await UserManager.shared.updateUserLastName(userId: user.userId, lastName: newValueLastName)
            self.user = try await UserManager.shared.getUser(userID: user.userId)
        }
    }
    

    func updatePhoneNumber() {
        guard let user else { return }
        let newValuephoneNumber = phoneNumber
        Task {
            try await UserManager.shared.updateUserPhoneNumber(userId:  user.userId, phoneNumber: newValuephoneNumber)
            self.user = try await UserManager.shared.getUser(userID: user.userId)
        }
    }
    
    func updateDateOfBirth() {
        guard let user else { return }
        let newValueDateOfBirth = dateOfBirth
        Task {
            try await UserManager.shared.updateUserDateOfBirth(userId: user.userId, dateOfBirth: newValueDateOfBirth)
            self.user = try await UserManager.shared.getUser(userID: user.userId)
        }
    }
    
}
