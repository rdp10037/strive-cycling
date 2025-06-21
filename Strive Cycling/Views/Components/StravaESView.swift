//
//  StravaESView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/19/25.
//

import SwiftUI

struct StravaESView: View {
    @State private var showingStravaLinkSheet = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(.stravaLogo)
                .resizable()
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .gray.opacity(0.3), radius: 16)
                .padding(.bottom, 12)

                          Text("Connect to Strava")
                              .font(.title2)
                              .fontWeight(.semibold)

                          Text("Link your Strava account to view your rides, track your progress, and unlock full dashboard insights.")
                              .font(.subheadline)
                              .foregroundColor(.secondary)
                              .multilineTextAlignment(.center)
                              .padding(.horizontal)

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
                          .padding(.horizontal)
                      }
                      .frame(maxWidth: .infinity, maxHeight: .infinity)
                      .padding()
                      .sheet(isPresented: $showingStravaLinkSheet) {
                          StravaPrimingView()
                              .presentationDetents([.large])
                              .interactiveDismissDisabled()
                      }
    }
}

#Preview {
    StravaESView()
}
