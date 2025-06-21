//
//  NutritionCSView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/18/25.
//

import SwiftUI

struct NutritionCSView: View {
    var body: some View {
    
        ScrollView {
                      VStack(spacing: 24) {
                          
                          Image(.striveFoodCSImg)
                              .resizable()
                              .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.width * 0.5)

                          Text("Wholistic Nutrition Tracking")
                              .font(.title)
                              .fontWeight(.semibold)

                          VStack(alignment: .leading, spacing: 10) {
                              Text("Support your performance with better nutrition. Strive will soon let you log meals, hydration, and nutrition data all in one place.")
                                  .multilineTextAlignment(.leading)

                              VStack(alignment: .leading, spacing: 6) {
                                  Label("Log daily meals and snacks", systemImage: "fork.knife")
                                  Label("Track hydration and water intake", systemImage: "drop.fill")
                                  Label("Monitor calories, macros, and nutrients", systemImage: "chart.bar.fill")
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
        .background(Color.background.gradient)
                  .navigationTitle("Nutrition")
    }
}

#Preview {
    NutritionCSView()
}
