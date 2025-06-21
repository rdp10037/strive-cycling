//
//  StravaAlreadyConnectedView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/20/25.
//

import SwiftUI

struct StravaAlreadyConnectedView: View {
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                Image(.stravaLogo)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .gray.opacity(0.3), radius: 16)
                    .padding(.bottom, 12)
            
                Text("You're Connected!")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Strava account is already connected to Strive.")
                    
                    Text("This means we’re able to import your rides and display your stats, trends, and history.")
                    
                    Text("If you ever wish to disconnect your Strava account, you can do so from the Profile tab.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
                .padding(.horizontal)
                
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Strava Connected")
        }
    }
}


#Preview {
    StravaAlreadyConnectedView()
}
