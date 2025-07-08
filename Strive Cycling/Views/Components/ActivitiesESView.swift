//
//  ActivitiesESView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/22/25.
//

import SwiftUI

struct ActivitiesESView: View {
    @EnvironmentObject var activityVM: StravaActivityViewModel
    
    var body: some View {
        VStack (spacing: 20){
            
            Image(.esImg)
                .resizable()
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .gray.opacity(0.3), radius: 16)
                .padding(.bottom, 12)

                          Text("No Recent Activities")
                              .font(.title2)
                              .fontWeight(.semibold)

                          Text("Looks like you haven't logged any activities yet. If you have, try resyncing your Strava account.")
                              .font(.subheadline)
                              .foregroundColor(.secondary)
                              .multilineTextAlignment(.center)
                              .padding(.horizontal)

                          Button(action: {
                              activityVM.fetchRecentActivities()
                          }) {
                              Label("Sync Activities", systemImage: "link")
                                  .padding()
                                  .frame(maxWidth: .infinity)
                                  .background(Color.icon)
                                  .foregroundColor(.white)
                                  .cornerRadius(22)
                          }
                          .padding()
        }
                  
    
    }
}

#Preview {
    ActivitiesESView()
        .environmentObject(StravaActivityViewModel())
}
