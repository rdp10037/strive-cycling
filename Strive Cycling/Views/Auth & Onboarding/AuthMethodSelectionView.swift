//
//  AuthMethodSelectionView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 7/23/25.
//

import SwiftUI

struct AuthMethodSelectionView: View {
    
    @EnvironmentObject var profileVm: ProfileViewModel
    @EnvironmentObject var viewModelAuth: AuthenticationViewModel
    @Environment(\.colorScheme) var currentScheme
    
    var body: some View {
        ScrollView {
            VStack {
                
                VStack (spacing: 8){
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primary)
                        .padding(.top)
                    
                    Text("Next, create your account with your preferred method.")
                        .font(.title2)
                     //   .fontWeight(.medium)
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 30)
                
                
                /// Vertical section
                VStack (spacing: 12){
    
                    /// Wide Apple Button
                    Button(action: {
                        Task {
                            do {
                                try await viewModelAuth.signInApple()
                       //         showSignInView = false
                            } catch {
                                print("Failed to do signInApple func")
                                print(error)
                            }
                        }
                    }, label: {
                        HStack {
                            Image(currentScheme == .light ? "appleButtonDark" : "appleButtonLight")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.trailing, -2)
                                .padding(.bottom, -4)
                            Text("Continue with Apple")
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                                .foregroundStyle(currentScheme == .dark ? .black : .white)
                                .padding(.trailing, 15)
                        }
                    })
                    .frame(width: UIScreen.main.bounds.width - 38, height: 52)
                    .background(currentScheme == .dark ? .white : .black)
                    .cornerRadius(14)
                    
                    /// Continue with Google button
                    Button(action: {
                        Task {
                            do {
                                try await viewModelAuth.signInGoogle()
                   //             showSignInView = false
                            } catch {
                                print("Failed to do signInGoogle func")
                                print(error)
                            }
                        }
                    }, label: {
                        HStack {
                            Image("googleButton")
                                .resizable()
                                .frame(width: 38, height: 38)
                            Text("Continue with Google")
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                                .foregroundStyle(currentScheme == .dark ? .black : .white)
                                .padding(.trailing, 15)
                        }
                    })
                    .frame(width: UIScreen.main.bounds.width - 38, height: 52)
                    .background(currentScheme == .dark ? .white : .black)
                    .cornerRadius(14)
       
                    
                    
                }
            }
        }
    }
}

#Preview {
    AuthMethodSelectionView()
}
