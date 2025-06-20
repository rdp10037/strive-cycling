//
//  ConnectedStravaView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/19/25.
//

import SwiftUI

struct ConnectStravaView: View {
    
    //  @Environment(\.dismiss) private var dismiss
    @Binding var showOnboardingView: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                Image(.stravaLogo)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .gray.opacity(0.3), radius: 16)
                    .padding(.bottom, 12)
            
                Text("Connect with Strava")
                    .font(.title)
                    .fontWeight(.bold)
            
                VStack(alignment: .leading, spacing: 16) {
                    Text("To get started, Strive connects with your Strava account to import your cycling activity data.")
                    
                    Text("This allows us to:")
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Display your ride history and stats", systemImage: "bicycle")
                        Label("Log nutrition and recovery data for each ride", systemImage: "leaf")
                        Label("Personalize your dashboard and insights", systemImage: "chart.bar")
                    }
                    
                    Text("Authentication is secure and handled through Strava. We only read data — nothing is posted or changed on your behalf.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
                .padding(.horizontal)
                
                // Connect Button
                Button(action: {
                    // Trigger OAuth flow
                }) {
                    Label("Connect to Strava", systemImage: "link")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.stravaOrange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Button {
                    showOnboardingView.toggle()
                } label: {
                    Text("Not Now")
                        .foregroundStyle(Color.secondary)
                }
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Get Started")
        }
    }
}


#Preview {
    ConnectStravaView(showOnboardingView: .constant(false))
}
