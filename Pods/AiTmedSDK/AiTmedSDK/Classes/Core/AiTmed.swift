//
//  AiTmed.swift
//  AiTmed-framework
//
//  Created by Yi Tong on 11/25/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

//The SDK has three layers
//1. grpc layer - call low level grpc
//2. conversion layer - convert paraments from application layer to edge, vertex, doc
//3. application layer - call conversion layer, expose to outside

import Foundation

public class AiTmed {
    ///Only use credential after login or create user
    var c: Credential!
    ///Encryption tool
    let e = Encryption()
    ///GRPC wrapper layer
    let g = GRPC()
    static let shared = AiTmed()
    private init() {}
    var tmpJWT: String = ""
}
