//
//  PayResponseDTO.swift
//  Pay
//
//  Created by Giga Khizanishvili on 12.07.24.
//

struct PayResponseDTO: Decodable {
    let status: Bool
    let url: String?
    // WebView -> listen to redirect
    // success -> close -> completionHandler
    // Failure -> close -> completionHandler

    // Set card number from wallet
    let threeDSIsPresent: Bool
    // isFalse -> no OTP -> Success if success
}
