//
//  StringProtocol.swift
//  AiTmedSDK
//
//  Created by Yi Tong on 2/14/20.
//

import Foundation
import PromiseKit

public extension StringProtocol {
    func toJSONDict() -> Promise<[String: Any]> {
        return Promise<[String: Any]> { resolver in
            if let data = self.data(using: .utf8),
                let dict = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] {
                resolver.fulfill(dict)
            } else {
                resolver.reject(AiTmedError.internalError(.dataCorrupted))
            }
        }
    }
    
    func toJSONDict() -> [String: Any]? {
        print("before:", self)
        if let data = data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                return json as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return nil
    }
}
