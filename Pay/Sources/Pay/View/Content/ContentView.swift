//
//  ContentView.swift
//  Pay
//
//  Created by Mariam Ormotsadze on 19.06.24.
//

import SwiftUI

struct ContentView: View {

    // MARK: - Properties
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject private var configuration: Configuration

    @StateObject private var viewModel = ContentViewModel()

    @State private var number = ""
    @State private var expirationDate = ""
    @State private var cvv = ""
    @State private var cardHolderName = ""

    // TODO: Change approach to be removed
    @State private var isNumberTextFieldEditing = false
    @State private var isExpirationDateTextFieldEditing = false
    @State private var isCVVTextFieldEditing = false
    @State private var isCardHolderNameTextFieldEditing = false

    @State private var isExpirationDatePickerPresented = false
    @State private var selectedMonth = 6
    @State private var selectedYear = Date.currentYear

    @State private var isAlertPresented = false
    @State private var alertTitle = "Error occurred"
    @State private var alertMessage = ""

    // MARK: - Body
    var body: some View {
        ZStack {
            configuration.colorPalette.background
                .edgesIgnoringSafeArea(.bottom)

            ZStack {
                VStack {
                    Divider()

                    if viewModel.amount == nil {
                        VStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        VStack {
                            contentBodyView
                            Spacer()
                            bottomView
                        }
                        .padding(.horizontal, 20)

                    }
                }

                if isExpirationDatePickerPresented {
                        ExpirationDatePickerView(
                            selectedMonth: $selectedMonth,
                            selectedYear: $selectedYear,
                            isPresented: $isExpirationDatePickerPresented
                        )
                }
            }
        }
        .disabled(viewModel.isLoading)
        .alert(isPresented: $isAlertPresented) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("Got It"))
            )
        }
        .onReceive(
            viewModel.errorPublisher.receive(on: DispatchQueue.main)
        ) { error in
            alertMessage = error.localizedDescription
            isAlertPresented = true
        }
        .onReceive(
            viewModel.dismissPublisher.receive(on: DispatchQueue.main)
        ) {
            presentationMode.wrappedValue.dismiss()
        }
        .onAppear {
            viewModel.viewDidAppear(withConfiguration: configuration)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                toolbarCloseButton
            }
        }
        .navigationTitle("Enter Card")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Components
private extension ContentView {
    var contentBodyView: some View {
        VStack(spacing: 12) {
            bannerView

            inputSection
        }
    }

    // MARK: Banner
    var bannerView: some View {
        HStack {
            configuration.companyIcon

            Spacer()

            VStack(alignment: configuration.companyIcon == nil ? .center : .trailing) {
                Text("Amount")
                    .font(.caption)
                    .foregroundColor(configuration.colorPalette.textSecondary)

                Text(viewModel.amount!.formatted())
                    .foregroundColor(configuration.colorPalette.textPrimary)
                    .bold()
            }

            if configuration.companyIcon == nil {
                Spacer()
            }
        }
        .padding(10)
        .background(configuration.colorPalette.surface)
        .cornerRadius(8)
    }

    var inputSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            numberTextField

            HStack {
                expirationDateTextField

                if let cardBrand = viewModel.cardBrand, cardBrand.hasCVV {
                    cvvTextField
                }
            }

            cardHolderNameTextField
        }
    }

    // MARK: Number
    var numberTextField: some View {
        ZStack(alignment: .center) {
            DefaultTextField(
                text: $number, 
                isEditing: $isNumberTextFieldEditing,
                title: "Number",
                placeHolder: "Required"
            )
            .keyboardType(.numberPad)
            .onChange(of: number) { number in
                viewModel.numberDidUpdate(to: number)
            }
            .onReceive(
                viewModel.updateCardNumberPublisher.receive(on: DispatchQueue.main)
            ) { newCardNumber in
                number = newCardNumber
            }

            if let cardBrand = viewModel.cardBrand {
                HStack(alignment: .bottom) {
                    Spacer()

                    cardBrand.icon
                        .resizable()
                        .frame(width: 45, height: 22)
                        .padding(.bottom)
                        .padding(.trailing)
                        .offset(y: 16)
                }
            }
        }
    }

    // MARK: Expiration Date
    var expirationDateTextField: some View {
        ZStack {
            DefaultTextField(
                text: $expirationDate,
                isEditing: $isExpirationDateTextFieldEditing,
                title: "Expires",
                placeHolder: "MM / YYYY"
            )
            .disabled(true)
            .onTapGesture {
                withAnimation {
                    isExpirationDatePickerPresented = true
                    updateExpirationDateText()
                }
            }
            .onChange(of: selectedMonth) { _ in
                updateExpirationDateText()
            }
            .onChange(of: selectedYear) { _ in
                updateExpirationDateText()
            }
            .onChange(of: isExpirationDatePickerPresented) { isExpirationDatePickerPresented in
                isExpirationDateTextFieldEditing = isExpirationDatePickerPresented
            }

            HStack {
                Spacer()

                Image(.arrowDown)
                    .frame(width: 50, height: 50)
                    .offset(x: 4, y: 8)
            }
        }
    }

    // MARK: - CVV
    var cvvTextField: some View {
        DefaultTextField(
            text: $cvv, 
            isEditing: $isCVVTextFieldEditing,
            title: "CVV",
            placeHolder: "Security Code"
        )
        .keyboardType(.numberPad)
    }

    // MARK: CardHolder
    var cardHolderNameTextField: some View {
        DefaultTextField(
            text: $cardHolderName,
            isEditing: $isCardHolderNameTextFieldEditing,
            title: "Card Holder Name",
            placeHolder: "Name"
        )
    }

    var bottomView: some View {
        VStack(spacing: 26) {
            nextButton

            FooterView()
                .padding(.bottom, 12)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea(.keyboard)
    }

    // MARK: Next
    var nextButton: some View {
        let hasCVV = viewModel.cardBrand?.hasCVV == true
        let isDisabled = (
            [number, expirationDate, cardHolderName]
            + (hasCVV ? [cvv] : [])
        )
            .reduce(false) { $0 || $1.isEmpty }

        return Button(
            action: {
                viewModel.pay(
                    number: number,
                    cardHolder: cardHolderName,
                    expirationDate: expirationDate,
                    securityNumber: cvv
                )
            },
            label: {
                ZStack {
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()

                            Spacer()
                        }
                    }
                    Text("Next")
                }
                .foregroundColor(configuration.colorPalette.surface)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(configuration.colorPalette.brand)
                        .opacity(isDisabled ? 0.4 : 1)
                )
            }
        )
        .disabled(isDisabled)
    }

    var toolbarCloseButton: some View {
        Button(
            action: {
                print("Close button did tap")
            },
            label: {
                Text("Close")
                    .foregroundColor(configuration.colorPalette.negative)
            }
        )
    }
}

// MARK: - Private
private extension ContentView {
    func updateExpirationDateText() {
        expirationDate = "\(selectedMonth.formattedToTwoDigits()) / \(selectedYear)"
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ContentView()
            .environmentObject(Configuration.example)
    }
}
