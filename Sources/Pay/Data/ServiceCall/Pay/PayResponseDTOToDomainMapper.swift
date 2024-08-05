//
//  PayResponseDTOToDomainMapper.swift
//
//
//  Created by Giga Khizanishvili on 05.08.24.
//

import Foundation

final class PayResponseDTOToDomainMapper {
    func map(_ dto: PayResponseDTO) -> PayResponse {
        if dto.threeDSIsPresent {
            return .otpWasRequired(
                url: URL(string: dto.url!)!
            )
        }

        if dto.status {
            return .success
        }

        return .failure
    }
}
