//
//  Optional.swift
//  AiTmedSDK
//
//  Created by Yi Tong on 2/14/20.
//

import Foundation

public extension Optional {
    func nilToThrow(_ error: Error) throws -> Wrapped {
        switch self {
        case .none:
            throw error
        case .some(let value):
            return value
        }
    }
}
