//
//  DashboardView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/18/25.
//

import SwiftUI
import Charts

struct DashboardView: View {
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
              
                    /// Top chart section (Not in use atm in favor of the heat map
//                    VStack (alignment: .leading){
//                        HStack {
//                            VStack (alignment: .leading){
//                                Label("Ride Time", systemImage: "figure.outdoor.cycle")
//                                    .font(.title3.bold())
//                                    .foregroundStyle(.pink)
//                                Text("Avg \(Int(avgRideTime)) minutes per ride")
//                                    .font(.caption)
//                            }
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                        }
//                        .padding(.bottom)
//                        
//                        Chart {
//                            RuleMark(y: .value("Goal", avgRideTime))
//                                .foregroundStyle(Color.secondary)
//                                .lineStyle(.init(lineWidth: 1, dash: [5]))
//                            
//                            ForEach(mockHistoricalData) { activity in
//                            BarMark(
//                                x: .value("Date", activity.date, unit: .day),
//                                y: .value("Duration", activity.duration)
//                                )
//                            .foregroundStyle(Color.pink.gradient)
//                            }
//                        }
//                    }
//                    .padding()
//                    .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
//                    .frame(height: UIScreen.main.bounds.width * 0.6)
                    
                    
                    HeatMapCalendarView()
                    
                    Button("Connect with Strava") {
                        StravaAuthManager.shared.authorize()
                    }
                    
                    Button {
                        StravaActivityManager.shared.fetchRecentActivities()
                    } label: {
                        Text("Fetch Activity")
                    }

                  
                    
                    /// Activity List Section
                    VStack(spacing: 20) {
                        ForEach(mockHistoricalData) { activity in
                            FeedActivityRowView(activity: activity)
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .padding()
            }
            .navigationTitle("My Activity")
            .scrollIndicators(.hidden)
        }
    }
}


#Preview {
    DashboardView()
}
