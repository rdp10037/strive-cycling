//
//  DashboardView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/18/25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    
    @EnvironmentObject var authVm: StravaAuthViewModel
    @EnvironmentObject var activityVM: StravaActivityViewModel
    
    @State private var streakCount = 4 // Placeholder
    @State private var todaysActivities: [Activity] = Activity.mockToday()
    @State private var friendActivities: [Activity] = Activity.mockFriends()
    
    @State private var mockHistoricalData: [Activity] = Activity.mockHistoricalData()
    
    @State private var showingStravaLinkSheet = false
    @State private var showStravaDisconnectView: Bool = false
    
    /// Calculate avg ride time for mock activity data
    var avgRideTime: Double {
        guard !mockHistoricalData.isEmpty else { return 0 }
        let totalTime = mockHistoricalData.reduce(0) { $0 + $1.duration }
        return Double(totalTime) / Double(mockHistoricalData.count)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                
                    /// Ride Time Heat Map Section
                    HeatMapCalendarView()
                    
                    Text("Recent Activities")
                        .font(.title2)
                        .fontWeight(.semibold)
         
                    if authVm.isAuthorized {
                        if activityVM.isLoading {
                            ProgressView()
                        } else if activityVM.activities.isEmpty {
                            ActivitiesESView()
                        } else {
                            ForEach(activityVM.activities) { activity in
                                NavigationLink {
                                    ActivityDetailView(activityId: activity.id)
                                } label: {
                                    StravaActivityRowView(activity: activity)
                                }
                                .foregroundStyle(Color.primary)
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    } else {
                        VStack (alignment: .leading, spacing: 30){
                            Text("Looks like your not authorized with Strava. Please connect to Strava to view your activities.")
                            
                            Button(action: {
                                showingStravaLinkSheet.toggle()
                            }) {
                                Label("Get Started", systemImage: "link")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.stravaOrange)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
                .task {
                    if authVm.isAuthorized {
                        if activityVM.activities.isEmpty {
                            await activityVM.fetchRecentActivities()
                        }
                    }
                }
            }
            .background(Color.background.gradient)
            .navigationTitle("My Activity")
            .scrollIndicators(.hidden)
            .refreshable {
                await activityVM.fetchRecentActivities()
            }
            .sheet(isPresented: $showingStravaLinkSheet) {
                  /// On dismiss, check if the user has a valid token, if so show Strava disconnected in app dynamic island notification
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
        }
    }
}


#Preview {
    DashboardView()
        .environmentObject(StravaAuthViewModel())
        .environmentObject(StravaActivityViewModel())
}
