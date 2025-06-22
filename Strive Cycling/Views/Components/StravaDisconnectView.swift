//
//  StravaDisconnectView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/22/25.
//

import SwiftUI

struct StravaDisconnectView: View {
    
    @EnvironmentObject var authVm: StravaAuthViewModel
    @EnvironmentObject var activityVM: StravaActivityViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            
            Image(.stravaLogo)
                .resizable()
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .gray.opacity(0.3), radius: 16)
                .padding(.bottom, 12)
        
            Text("Disconnect from Strava")
                .font(.title)
                .fontWeight(.bold)
        
            VStack(alignment: .leading, spacing: 16) {
                Text("This will disconnect your Strava account from Strive Cycling and remove all access to your Strava data.")
            }
            .font(.subheadline)
            .padding(.horizontal)
            
            Button {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    activityVM.clearActivities()
//                }
                authVm.disconnect()
                dismiss()
                /// On dismiss, check if the user has a valid token, if so show Strava linked in app dynamic island notification
                if !authVm.isAuthorized {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        UIApplication.shared.inAppNotification(adaptForDynamicIsland: true, timeout: 3.8, swipeToClose: true) {
                            InAppNotificationPopOver(headline: "Strava Disconnected", bodyText: "Strava has been disconnected", sfSymbol: nil, customImage: .stravaLogo)
                        }
                    }
                }
            } label: {
                Text("Disconnect from Strava")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                    .padding()
            }
            
            
            Button {
                dismiss()
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

#Preview {
    StravaDisconnectView()
        .environmentObject(StravaAuthViewModel())
        .environmentObject(StravaActivityViewModel())
}
