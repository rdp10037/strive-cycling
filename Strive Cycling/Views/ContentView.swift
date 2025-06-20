//
//  ContentView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/18/25.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var showOnboarding = false
    
    
    var body: some View {
        MainView()
            .onAppear {
                  showOnboarding = !hasCompletedOnboarding
              }
              .sheet(isPresented: $showOnboarding) {
                  OnboardingFlowView(showOnboardingView: $showOnboarding)
                      .presentationDetents([.large])
                      .interactiveDismissDisabled()
              }
    }
}

#Preview {
    ContentView()
}
