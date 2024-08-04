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

    private let months = Array(1...12)
    private let years = Array(Date.currentYear...2100)

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
                    Picker("Month", selection: $selectedMonth) {
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
                Color.white // TODO: Should white be used directly? This is from Figma
                    .ignoresSafeArea()
            )
        }
    }
}

// MARK: - Components
private extension ExpirationDatePickerView {
    var headerView: some View {
        HStack(alignment: .center) {
            Text("Choose expiration date")

            Spacer()

            Button("Done") {
                withAnimation {
                    isPresented = false
                }
            }
        }
//        .padding(.horizontal)
//        .padding(.top)
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
