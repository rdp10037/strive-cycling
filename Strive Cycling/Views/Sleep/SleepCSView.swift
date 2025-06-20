//
//  SleepCSView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/18/25.
//

import SwiftUI

struct SleepCSView: View {
    var body: some View {
        
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .foregroundStyle(.blue.opacity(0.25))
                        .frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.width * 0.4)
                    Circle()
                        .foregroundStyle(.gray.opacity(0.1))
                        .frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.width * 0.4)
                    
                    Image(.sleepCSImg)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.width * 0.5)
                }
                
                Text("Sleep Tracking")
                    .font(.title)
                    .fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Keep tabs on your rest and recovery. Strive will soon support automatic sleep tracking from devices like Apple Watch and other health platforms.")
                        .multilineTextAlignment(.leading)

                    VStack(alignment: .leading, spacing: 6) {
                        Label("View nightly sleep stats and duration", systemImage: "bed.double.fill")
                        Label("Monitor trends in sleep quality", systemImage: "waveform.path.ecg")
                        Label("Track recovery habits alongside ride data", systemImage: "bicycle.circle")
                    }
                    .padding(.top, 8)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Text("Coming Soon")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 28)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 10)
                    .padding()
       
                Spacer()
            }
            .multilineTextAlignment(.center)
            .padding(.vertical, 40)
        }
        .navigationTitle("Sleep")
    }
}

#Preview {
    SleepCSView()
}
