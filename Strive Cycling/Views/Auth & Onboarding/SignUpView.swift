//
//  SignUpView.swift
//  Stacks
//
//  Created by Rob Pee on 6/18/23.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth


struct SignUpView: View {
    
    @EnvironmentObject var profileVm: ProfileViewModel
    @EnvironmentObject var viewModelAuth: AuthenticationViewModel
    @Environment(\.colorScheme) var currentScheme

    @State private var offset = CGSize.zero
    
    @Environment(\.dismiss) private var dismiss
    @Binding var showSignInView: Bool
    @Binding var showOnboardingView: Bool
    
    @State private var showPins: Bool = false
    @State private var showPinSection: Bool = false
    
    @State private var showTextSection: Bool = false
    
    @State private var showingPrivacySheet: Bool = false
    
    var body: some View {
        
        
        ZStack (alignment: .top){
            ZStack {
//                Image(.bhMural)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: UIScreen.main.bounds.width)
//              //      .frame(height: UIScreen.main.bounds.height * 0.6)
//                    .edgesIgnoringSafeArea(.all)
//                    .overlay {
//                        LinearGradient(gradient: Gradient(colors: [.clear, .clear, .clear, .icon.opacity(0.15), .icon]), startPoint: .top, endPoint: .bottom)
//                    }
            }
            .overlay {
                LinearGradient(gradient: Gradient(colors: [.clear, .clear, .icon.opacity(0.15), .icon]), startPoint: .top, endPoint: .bottom)
            }
            
            VStack (alignment: .center){
         
                Spacer()
                
                VStack {
                    VStack {
                        
                        VStack (alignment: .center) {

                            Text("Welcome to Strive")
                                .font(.system(size: 36, weight: .bold))
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primary)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 10)
                            Text("The ultimate health & wellness assistant to help you discover, plan, and improve.")
                                .font(.body)
                                .fontWeight(.regular)
                                .foregroundStyle(Color.secondary)
                                .multilineTextAlignment(.center)
                
                            VStack {
                                HStack {
                                    VStack {
                                        Divider()
                                    }
                                    Text("Sign Up With")
                                        .padding(.horizontal, 20)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                        .frame(width: 150)
                                    VStack {
                                        Divider()
                                    }
                                }
                                .foregroundStyle(.primary)
                                .padding(.vertical, 12)
                            }
                        }
                        .padding()
                        
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
                    .padding(.bottom, 10)
                    
            
                    
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(.secondary)
                            
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(height: 55)
                                .cornerRadius(16)
                            
                        }
                        .frame(width: 300)
                    //    .padding(.bottom, 10)
                    }
  
                }
                .padding(.bottom)
                .offset(y: showTextSection ? 0 : 80)
                .opacity(showTextSection ? 1 : 0)
            }
            .padding()
            //    }
            .frame(width: UIScreen.main.bounds.width)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                    withAnimation(.bouncy) {
                        showTextSection = true
                    }
                }
                )
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                                    Button {
                dismiss()
            } label: {
                
                CustomBackButton()
            }
            )
        }
        .background(Color.icon)
        //       .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea()
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignUpView(showSignInView: .constant(false), showOnboardingView: .constant(false))
                .environmentObject(ProfileViewModel())
                .environmentObject(AuthenticationViewModel())
        }
    }
}
