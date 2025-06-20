//
//  OnboardingFlowView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/19/25.
//

import SwiftUI

struct OnboardingFlowView: View {
    @State private var showStravaView = false
    @Binding var showOnboardingView: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 42) {
                    // 🎉 Welcome
                    VStack(spacing: 12) {
                        Image(.striveLogo)
                            .resizable()
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .gray.opacity(0.3), radius: 16)
                            .padding(.bottom, 22)
                            .padding(.top, 40)
                        
                        Text("Welcome to Strive")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Track your rides, fuel smarter, and stay connected through Strava.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    
                    // 🚀 Button
                    Button(action: {
                        showStravaView = true
                    }) {
                        Text("Get Started")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.icon)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 60)
                .navigationDestination(isPresented: $showStravaView) {
                    ConnectStravaView(showOnboardingView: $showOnboardingView)
                }
            }
        }
    }
}


#Preview {
    OnboardingFlowView(showOnboardingView: .constant(false))
}
