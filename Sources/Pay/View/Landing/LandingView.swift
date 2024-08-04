//
//  LandingView.swift
//  Pay
//
//  Created by Giga Khizanishvili on 04.08.24.
//

import SwiftUI

struct LandingView: View {
    var body: some View {
        VStack {
            Spacer()

            NavigationLink(
                destination: {
                    let configuration: Configuration = .example
                    return ContentView()
                        .environmentObject(configuration)
                },
                label: {
                    Text("Pay for the transaction 💵")
                }
            )

            Spacer()
        }
    }
}

#Preview {
    LandingView()
}
