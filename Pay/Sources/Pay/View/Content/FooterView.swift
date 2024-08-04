//
//  FooterView.swift
//  Pay
//
//  Created by Giga Khizanishvili on 03.07.24.
//

import SwiftUI

struct FooterView: View {

    @EnvironmentObject private var configuration: Configuration

    var body: some View {
        VStack(spacing: 4) {
            Text("Powered By")
                .foregroundColor(configuration.colorPalette.textSecondary)

            Image(.payze)
                .renderingMode(.template)
                .opacity(0.7)
                .blendMode(.luminosity)
                .foregroundColor(configuration.colorPalette.textSecondary)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Spacer()
        FooterView()
            .environmentObject(Configuration.example)
    }
}
