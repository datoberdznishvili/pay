//
//  PayResponseDTOToDomainMapper.swift
//
//
//  Created by Giga Khizanishvili on 05.08.24.
//

import Foundation

final class PayResponseDTOToDomainMapper {
    func map(_ dto: PayResponseDTO) -> PayResponse {
        if dto.threeDSIsPresent, let urlString = dto.url {
            return .otpWasRequired(
                url: URL(string: urlString)!
            )
        } else {
            return .success
        }
    }
}
