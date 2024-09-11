//
//  ExpirationDatePickerView.swift
//  Pay
//
//  Created by Giga Khizanishvili on 03.07.24.
//

import SwiftUI

struct ExpirationDatePickerView: View {
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int
    @Binding var isPresented: Bool

    @Injected private var configuration: Configuration

    private let months = Array(1...12)
    private let years = Array(Date.currentYear...(Date.currentYear + 5))

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            Color.gray
                .opacity(0.4)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }

            VStack(spacing: 0) {
                headerView

                HStack {
                    Picker("Month", selection: $selectedMonth) { // TODO: Localize
                        ForEach(months, id: \.self) { month in
                            Text(month.formattedToTwoDigits())
                                .tag(month)
                        }
                    }

                    Picker("Year", selection: $selectedYear) { 
                        ForEach(years, id: \.self) { year in
                            Text("\(year)".removingWhitespaces())
                                .tag(year)
                        }
                    }
                }
                .pickerStyle(.wheel)
            }
            .background(
                configuration.colorPalette.surface
                    .ignoresSafeArea()
            )
        }
    }
}

// MARK: - Components
private extension ExpirationDatePickerView {
    var headerView: some View {
        HStack(alignment: .center) {
            Text(LocalizationKey.ExpirationDate.title())

            Spacer()

            Button(LocalizationKey.ExpirationDate.done()) {
                withAnimation {
                    isPresented = false
                }
            }
        }
        .padding(.top)
        .padding(.horizontal)
    }
}

// MARK: - Preview
#Preview {
    ExpirationDatePickerView(
        selectedMonth: .constant(5),
        selectedYear: .constant(2026),
        isPresented: .constant(true)
    )
}
