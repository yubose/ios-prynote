//
//  Util.swift
//  AiTmedSDK
//
//  Created by Yi Tong on 2/14/20.
//

import Foundation

func isZipSatisified(for data: Data, mediaType: MediaType) -> Bool {
    switch mediaType.kind {
    case .image, .video:
        return false
    default:
        do {
            if data.count < Config.minimumZipDataSize {//don't zip below minimumZipDataSize
                return false
            } else {//large than minimumZipDataSize, compare size of zipped and unzipped
                let zipped = try data.zip()
                return zipped.count < data.count
            }
        } catch {
            return false
        }
    }
}

func isOnServerSatisfied(for data: Data) -> Bool {
    return data.count <= Config.maximumServerDataSize
}
