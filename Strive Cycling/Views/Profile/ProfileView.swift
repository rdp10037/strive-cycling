//
//  ProfileView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/20/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: StravaAuthViewModel
    @EnvironmentObject var activityVM: StravaActivityViewModel
    
    @State private var showingDisconnectSheet: Bool = false
    @State private var showStravaDisconnectView: Bool = false

    var body: some View {
        NavigationView {
            if authVM.isAuthorized {
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: - Profile Header
                        if let athlete = authVM.athlete {
                            VStack(spacing: 8) {
                                if let url = URL(string: athlete.profile), !athlete.profile.isEmpty {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                            .shadow(radius: 6)
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 80, height: 80)
                                    }
                                }
                                
                                Text("\(athlete.firstname) \(athlete.lastname)")
                                    .font(.title2)
                                    .bold()
                                
                                if let city = athlete.city, !city.isEmpty {
                                    Text(city)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        // MARK: - Recent Ride Stats
                        if let stats = authVM.stats, let rides = stats.recentRideTotals {
                            StatsSection(title: "Recent Cycling Stats", totals: rides)
                        }
                        
                        // MARK: - YTD Ride Stats
                        if let stats = authVM.stats, let rides = stats.ytdRideTotals {
                            StatsSection(title: "Year-to-Date Cycling Stats", totals: rides)
                        }
                        
                        // MARK: - Lifetime Ride Stats
                        if let stats = authVM.stats, let rides = stats.allRideTotals {
                            StatsSection(title: "Lifetime Cycling Stats", totals: rides)
                        }
                        
                        // MARK: - Actions
                        VStack(spacing: 16) {
                            Button() {
                                showStravaDisconnectView.toggle()
                            } label: {
                                Text("Disconnect from Strava")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(12)
                                    .padding()
                            }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal)
                
                        
                        Spacer()
                    }
                    .padding(.top, 40)
                    .task {
                        if authVM.stats == nil {
                            await authVM.fetchAthleteStats()
                        }
                        
                    }
                }
                .background(Color.background.gradient)
                .navigationTitle("Profile")
                .refreshable {
                    await authVM.fetchAthleteStats()
                }
                .sheet(isPresented: $showStravaDisconnectView) {
                    StravaDisconnectView()
                        .presentationDetents([.large])
                        .interactiveDismissDisabled(true)
                }
            } else {
                StravaESView()
            }
        }
    }
}

private struct StatsSection: View {
    let title: String
    let totals: StravaActivityTotals

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 4)

            StatRow(label: "Rides", value: "\(totals.count)")

            let distanceMi = totals.distance / 1609.34
            StatRow(label: "Distance", value: String(format: "%.1f mi", distanceMi))

            let hours = Int(totals.movingTime) / 3600
            StatRow(label: "Ride Time", value: "\(hours) hr")

            StatRow(label: "Elevation Gain", value: "\(Int(totals.elevationGain)) m")
        }
        .padding(.horizontal)
    }
}

private struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    ProfileView()
        .environmentObject(StravaAuthViewModel())
        .environmentObject(StravaActivityViewModel())
}
