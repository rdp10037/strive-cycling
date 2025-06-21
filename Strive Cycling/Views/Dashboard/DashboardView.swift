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
                    if activityVM.isLoading {
                        ProgressView()
                    } else if let error = activityVM.errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                    } else {
                        ForEach(activityVM.activities) { activity in
                            NavigationLink {
                                ActivityDetailView(activity: activity)
                            } label: {
                                StravaActivityRowView(activity: activity)
                            }
                            .foregroundStyle(Color.primary)
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
                .padding()
                .onAppear {
                    if activityVM.activities.isEmpty {
                        activityVM.fetchRecentActivities()
                    }
                }
               
            }
            .navigationTitle("My Activity")
            .scrollIndicators(.hidden)
            .refreshable {
                activityVM.fetchRecentActivities()
            }
        }
    }
}


#Preview {
    DashboardView()
        .environmentObject(StravaAuthViewModel())
        .environmentObject(StravaActivityViewModel())
}
