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
               
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
            }
        }
        .background(Color.background)
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
