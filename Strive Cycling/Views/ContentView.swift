//
//  ContentView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/18/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVm: StravaAuthViewModel
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var showOnboarding = false
    @State private var showStravaReAuthSheet: Bool = false
    
    var body: some View {
        MainView()
            .onAppear {
                  showOnboarding = !hasCompletedOnboarding
                
                if hasCompletedOnboarding {
                    if !authVm.isAuthorized {
                        showStravaReAuthSheet.toggle()
                    }
                }
              }
              .sheet(isPresented: $showOnboarding) {
                  /// Mark onboarding as finished on dismiss of onboarding sheet
                  hasCompletedOnboarding = true
                  
                  /// Check if the user has a valid token, if so show Strava linked in app dynamic island notification
                  if authVm.isAuthorized {
                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                          UIApplication.shared.inAppNotification(adaptForDynamicIsland: true, timeout: 3.8, swipeToClose: true) {
                              InAppNotificationPopOver(headline: "Strava Connected!", bodyText: "Strava is linked to your account.", sfSymbol: nil, customImage: .stravaLogo)
                          }
                      }
                  }
              } content: {
                  OnboardingFlowView(showOnboardingView: $showOnboarding)
                      .presentationDetents([.large])
                      .interactiveDismissDisabled()
              }
              .sheet(isPresented: $showStravaReAuthSheet) {
                
                  /// On dismiss, check if the user has a valid token, if so show Strava linked in app dynamic island notification
                  if authVm.isAuthorized {
                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                          UIApplication.shared.inAppNotification(adaptForDynamicIsland: true, timeout: 3.8, swipeToClose: true) {
                              InAppNotificationPopOver(headline: "Strava Connected!", bodyText: "Strava is linked to your account.", sfSymbol: nil, customImage: .stravaLogo)
                          }
                      }
                  }
                  
              } content: {
                  StravaPrimingView()
                      .presentationDetents([.large])
                      .interactiveDismissDisabled()
              }
              .task {
                  await authVm.fetchAthleteProfile()
              }
    }
}

#Preview {
    ContentView()
        .environmentObject(StravaAuthViewModel())
}
