//
//  FeedActivityRowView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/18/25.
//

import SwiftUI


struct FeedActivityRowView: View {
    
    let activity: Activity
    
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "mappin")
                    
                VStack (alignment: .leading, spacing: 4){
                    HStack (spacing: 8){
                        Text(activity.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                        
                        Text(activity.date, format: .dateTime.day().month().year())
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    
                    Text(activity.description)
                        .font(.body)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
//                Image(systemName: "ellipsis")
//                    .padding(.trailing, 10)
            }

            HStack {
                RoundedRectangle(cornerRadius: 14)
                    .foregroundStyle(Color.green.opacity(0.3))
                    .frame(width: UIScreen.main.bounds.width * 0.6, height: 160)
                    .overlay {
                        ZStack {
                            VStack {
                                Image(systemName: "mappin")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                            }
                        }
                      
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14))
               //     .padding(.trailing, 6)
                
                VStack (alignment: .leading){
                    VStack (alignment: .leading){
                        HStack {
                            Text(activity.distance.asNumberString())
                                .font(.headline)
                            Text("mi")
                                .font(.subheadline)
                        }
                        Text("Distance")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(2)
                    VStack (alignment: .leading){
                        HStack {
                            Text(activity.duration.asNumberString())
                                .font(.headline)
                            Text("min")
                                .font(.subheadline)
                        }
                        Text("Duration")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(2)
         
                    VStack (alignment: .leading){
                        HStack {
                            Text("\(activity.calories)")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("kcal")
                                .font(.subheadline)
                        }
                        Text("Energy")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(2)
                }
                .frame(minWidth: 90, minHeight: 160)
                Spacer()
            }
        }
   //     .padding(.horizontal)
    }
}


#Preview {
    FeedActivityRowView(activity: Activity(name: "Example", distance: 50, duration: 40, userName: "userName", activityType: "Ride", activitySubType: "Road", date: Date(), calories: 500, description: "Example activity description of my example run..."))
}
