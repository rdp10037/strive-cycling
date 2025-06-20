//
//  MainView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/18/25.
//

import SwiftUI

struct MainView: View {
    @State private var showingStravaLinkSheet = false
    var body: some View {
        NavigationStack {
            TabView {
                
                DashboardView()
                    .tabItem {
                        Label("Activity", systemImage: "figure.outdoor.cycle")
                    }

                NutritionView()
                    .tabItem {
                        Label("Nutrition", systemImage: "leaf")
                    }
                
                SleepMainView()
                    .tabItem {
                        Label("Sleep", systemImage: "bed.double")
                    }
               
                ProfileMainView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
            }
            .onAppear {
                print("TEST_KEY:", Bundle.main.object(forInfoDictionaryKey: "TEST_KEY") ?? "❌ MISSING")

                let clientId = Bundle.main.object(forInfoDictionaryKey: "STRAVA_CLIENT_ID") as? String ?? "Missing"
                               let clientSecret = Bundle.main.object(forInfoDictionaryKey: "STRAVA_CLIENT_SECRET") as? String ?? "Missing"
                               
                               print("✅ Client ID:", clientId)
                               print("✅ Client Secret:", clientSecret)

             //   showingStravaLinkSheet.toggle()
            }
        }
        .sheet(isPresented: $showingStravaLinkSheet) {
            StravaPrimingView()
                .presentationDetents([.large])
                .interactiveDismissDisabled()
        }
    }
}

#Preview {
    MainView()
}
