//
//  UserManager.swift
//  Strive Cycling
//
//  Created by Rob Pee on 7/23/25.
//

import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift


// Main User Document:
struct DBUser: Codable {
    let userId: String
    let email: String?
    let phoneNumber: String?
    let firstName: String?
    let lastName: String?
    let userName: String?
    let dateOfBirth: Date?
    let photoUrl: String?
    let dateCreated: Date?
    let isOnboarded: Bool
    let isPremium: Bool?
    let isMerchantAdmin: Bool?
    let merchantAdminId: [String]?
    let userAvatar: String?
    // let stravaConnected: Bool?
    // let stravaAthleteId: String?
    
    init (auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.phoneNumber = ""
        self.firstName = ""
        self.lastName = ""
        self.userName = ""
        self.dateOfBirth = Date()
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isOnboarded = true
        self.isPremium = false
        self.isMerchantAdmin = false
        self.merchantAdminId = []
        self.userAvatar = ""
    }
    
    init (
        userId: String,
        email: String? = nil,
        phoneNumber: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        userName: String? = nil,
        dateOfBirth: Date? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        isOnboarded: Bool,
        isPremium: Bool? = nil,
        isMerchantAdmin: Bool? = nil,
        merchantAdminId: [String]? = nil,
        userAvatar: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
        self.dateOfBirth = dateOfBirth
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isOnboarded = isOnboarded
        self.isPremium = isPremium
        self.isMerchantAdmin = isMerchantAdmin
        self.merchantAdminId = merchantAdminId
        self.userAvatar = userAvatar
    }
   
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case phoneNumber = "phone_number"
        case firstName = "first_name"
        case lastName = "last_name"
        case userName = "user_name"
        case dateOfBirth = "date_of_birth"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case isOnboarded = "is_onboarded"
        case isPremium = "is_premium"
        case isMerchantAdmin = "is_merchant_admin"
        case merchantAdminId = "merchant_admin_id"
        case userAvatar = "user_avatar"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.userName = try container.decodeIfPresent(String.self, forKey: .userName)
        self.dateOfBirth = try container.decodeIfPresent(Date.self, forKey: .dateOfBirth)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.isOnboarded = try container.decode(Bool.self, forKey: .isOnboarded)
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
        self.isMerchantAdmin = try container.decodeIfPresent(Bool.self, forKey: .isMerchantAdmin)
        self.merchantAdminId = try container.decodeIfPresent([String].self, forKey: .merchantAdminId)
        self.userAvatar = try container.decodeIfPresent(String.self, forKey: .userAvatar)
    }
    
    func encode1(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(self.firstName, forKey: .firstName)
        try container.encodeIfPresent(self.lastName, forKey: .lastName)
        try container.encodeIfPresent(self.userName, forKey: .userName)
        try container.encodeIfPresent(self.dateOfBirth, forKey: .dateOfBirth)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.isOnboarded, forKey: .isOnboarded)
        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
        try container.encodeIfPresent(self.isMerchantAdmin, forKey: .isMerchantAdmin)
        try container.encodeIfPresent(self.merchantAdminId, forKey: .merchantAdminId)
        try container.encodeIfPresent(self.userAvatar, forKey: .userAvatar)
    }
    
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    
    private func userDocument(userID: String) -> DocumentReference {
        userCollection.document(userID)
    }
    
    /// User activities sub-collection ref
    private func userActivitiesCollection(userId: String) -> CollectionReference {
        userDocument(userID: userId).collection("activities")
    }
    
    /// User activity Doc ref
    private func userActivitiesDocument(userId: String, activityId: String) -> DocumentReference {
        userActivitiesCollection(userId: userId).document(activityId)
    }


    func createNewUser(user: DBUser) async throws {
        try userDocument(userID: user.userId).setData(from: user, merge: true)
    }
    
    func userExists(userID: String) async throws -> Bool {
        var status: Bool = true
        
        let result = try await userDocument(userID: userID).getDocument(as: DBUser?.self)
        if result == nil {
            status = false
        }
        return status
    }
    
    func getUser(userID: String) async throws -> DBUser {
        try await userDocument(userID: userID).getDocument(as: DBUser.self)
    }

    // Premium Status
    func updateUserPremiumStatus(userId: String, isMerchantAdmin: Bool) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.isMerchantAdmin.rawValue : isMerchantAdmin
        ]
        try await userDocument(userID: userId).updateData(data)
    }
    
    // Phone Number
    func updateUserPhoneNumber(userId: String, phoneNumber: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.phoneNumber.rawValue : phoneNumber
        ]
        try await userDocument(userID: userId).updateData(data)
    }
    
    
    // User Avatar
    func updateUserAvatar(userId: String, userAvatar: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.userAvatar.rawValue : userAvatar
        ]
        try await userDocument(userID: userId).updateData(data)
    }
    
    // Is new status (used for varius onboarding/permissions)
    func updateUserIsNewStatus(userId: String, isOnboarded: Bool) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.isOnboarded.rawValue : isOnboarded
        ]
        try await userDocument(userID: userId).updateData(data)
    }
    
    // First Name
    func updateUserFirstName(userId: String, firstName: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.firstName.rawValue : firstName
        ]
        try await userDocument(userID: userId).updateData(data)
    }
    
    // Last Name
    func updateUserLastName(userId: String, lastName: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.lastName.rawValue : lastName
        ]
        try await userDocument(userID: userId).updateData(data)
    }
    
    // user Name
    func updateUserName(userId: String, userName: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.userName.rawValue : userName
        ]
        try await userDocument(userID: userId).updateData(data)
    }
    
    // Date of birth
    func updateUserDateOfBirth(userId: String, dateOfBirth: Date) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.dateOfBirth.rawValue : dateOfBirth
        ]
        try await userDocument(userID: userId).updateData(data)
    }

    // MARK: User Subcollections
    
 

}


extension DBUser {
    static var MOCK_USER = DBUser(userId: NSUUID().uuidString, firstName: "David", lastName: "Smith", userName: "D-man-007", isOnboarded: true)
}
