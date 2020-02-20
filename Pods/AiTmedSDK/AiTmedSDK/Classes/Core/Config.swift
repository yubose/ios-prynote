//
//  Config.swift
//  AiTmedSDK
//
//  Created by Yi Tong on 2/14/20.
//

import Foundation

enum Config {
    static let grpcTimeout: TimeInterval = 15
    static let host = "testapi2.aitmed.com:443"
    static let maximumServerDataSize = 32 * 1024
    static let minimumZipDataSize = 512
    static let cacheLifeTime: TimeInterval = 3600
    static let cacheMaximumCount = Int.max
}
