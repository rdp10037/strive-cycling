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
                
               /// If the user is onboarded proceed to checking token status. We have a 2.5 sec delay here to given the authVm.refreshTokenIfNeeded func in our task block below  time to attempt refresh.
                if hasCompletedOnboarding {
                    if !authVm.isAuthorized {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            showStravaReAuthSheet.toggle()
                        }
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
                  if hasCompletedOnboarding {
                      await authVm.refreshTokenIfNeeded()
                      await authVm.fetchAthleteProfile()
                  }
              }
    }
}

#Preview {
    ContentView()
        .environmentObject(StravaAuthViewModel())
}
