//
//  Array+.swift
//  AiTmedSDK
//
//  Created by Yi Tong on 2/14/20.
//

import Foundation

public extension Array where Element == UInt8 {
    var data: Data {
        return Data(self)
    }
}
