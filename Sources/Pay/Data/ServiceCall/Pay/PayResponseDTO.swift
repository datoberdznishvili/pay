//
//  PayResponseDTO.swift
//  Pay
//
//  Created by Giga Khizanishvili on 12.07.24.
//

struct PayResponseDTO: Decodable {
    let url: String?
    let threeDSIsPresent: Bool
}
