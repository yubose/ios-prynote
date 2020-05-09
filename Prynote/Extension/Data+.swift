//
//  Data+.swift
//  Prynote
//
//  Created by tongyi on 2/20/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension Data {
    func asyncString(completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global().async {
            if let str = String(bytes: self, encoding: .utf8) {
                completion(.success(str))
            } else {
                completion(.failure(PrynoteError.unkown))
            }
        }
    }
}


