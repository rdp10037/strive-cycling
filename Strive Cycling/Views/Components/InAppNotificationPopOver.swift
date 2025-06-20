//
//  InAppNotificationPopOver.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/20/25.
//

import SwiftUI

struct InAppNotificationPopOver: View {
    @State private var checkmark = false
    
    let headline: String
    let bodyText: String
    let sfSymbol: String?
    let customImage: ImageResource?
    
    var body: some View {

        HStack {
            if sfSymbol != nil {
                Image(systemName: !checkmark ? "calendar" : "checkmark.circle")
                    .contentTransition(.symbolEffect(.replace))
                    .font(!checkmark ? .title2 : .title)
                    .foregroundStyle(!checkmark ? Color.orange : Color.green)
                    .frame(width: 42, height: 42)
                    .background(.ultraThinMaterial.opacity(0.6))
                    .clipShape(Circle())
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
            } else if customImage != nil {
                Image(customImage ?? .striveLogo)
                    .resizable()
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
            } else {
                Image(systemName: !checkmark ? "calendar" : "checkmark.circle")
                    .contentTransition(.symbolEffect(.replace))
                    .font(!checkmark ? .title2 : .title)
                    .foregroundStyle(!checkmark ? Color.orange : Color.green)
                    .frame(width: 42, height: 42)
                    .background(.ultraThinMaterial.opacity(0.6))
                    .clipShape(Circle())
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
            }
            
     
            
            VStack (alignment: .leading, spacing: 6, content: {
                Text(headline)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
                
                Text(bodyText)
                    .font(.footnote)
                    .foregroundStyle(Color.gray)
                    .lineLimit(1)
            })
      
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            Spacer(minLength: 30)
            
            if customImage != nil {
                Image(systemName: !checkmark ? "circle.dotted" : "checkmark.circle")
                    .contentTransition(.symbolEffect(.replace))
                    .font(!checkmark ? .title2 : .title)
                    .foregroundStyle(!checkmark ? Color.gray : Color.green)
                    .frame(width: 38, height: 38)
                    .background(.ultraThinMaterial.opacity(0.6))
                    .clipShape(Circle())
                    .padding(.horizontal, 2)
                    .padding(.top, 10)
            }
       

        }
        .padding(15)
        .background {
            RoundedRectangle(cornerRadius: 36)
                .fill(.black)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2){
                checkmark.toggle()
            }
        }
        .sensoryFeedback(.success, trigger: checkmark)
        
    }
}

#Preview {
    InAppNotificationPopOver(headline: "Example Headlines", bodyText: "Example Body Text", sfSymbol: nil, customImage: .stravaLogo)
}
