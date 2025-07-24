//
//  CustomBackButton.swift
//  Nudge
//
//  Created by Rob Pee on 7/1/24.
//

import SwiftUI

struct CustomBackButton: View {
    var body: some View {
        Circle()
            .foregroundStyle(.ultraThinMaterial)
            .frame(width: 32)
            .overlay {
                Image(systemName: "chevron.left")
                    .font(.footnote)
                    .foregroundStyle(.primary)
            }
    }
}

#Preview {
    CustomBackButton()
}
