//
//  PayResponseDTOToDomainMapper.swift
//
//
//  Created by Giga Khizanishvili on 05.08.24.
//

import Foundation

final class PayResponseDTOToDomainMapper {
    func map(_ dto: PayResponseDTO) -> PayResponse {
        if dto.status {
            return .success
        }

        if dto.threeDSIsPresent {
            return .otpWasRequired(
                url: URL(string: dto.url!)!
            )
        }

        return .failure
    }
}
