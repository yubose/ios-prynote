//
//  Dictionary+.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/9/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import PromiseKit

public extension Dictionary where Key == AiTmedNameKey {
    func toJSON() -> Promise<String> {
        return Promise<String> { resolver in
            var newDict: [String: Value] = [:]
            for (key, value) in self {
                newDict[key.rawValue] = value
            }
            
            guard let data = try? JSONSerialization.data(withJSONObject: newDict, options: []),
                    let json = String(bytes: data, encoding: .utf8) else {
                        resolver.reject(AiTmedError.internalError(.dataCorrupted))
                return
            }
            
            resolver.fulfill(json)
        }
    }
    
    func toJSON() -> String? {
        var newDict: [String: Value] = [:]

        for (key, value) in self {
            newDict[key.rawValue] = value
        }

        guard let data = try? JSONSerialization.data(withJSONObject: newDict, options: []) else { return nil }
        return String(bytes: data, encoding: .utf8)
    }
}

public extension Dictionary where Key == String {
    func toJSON() -> Promise<String> {
        return Promise<String> { resolver in
            guard let data = try? JSONSerialization.data(withJSONObject: self, options: []),
                let json = String(bytes: data, encoding: .utf8) else {
                    resolver.reject(AiTmedError.internalError(.dataCorrupted))
                    return
            }
            
            resolver.fulfill(json)
        }
    }
    
    func toJSON() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        return String(bytes: data, encoding: .utf8)
    }
}
