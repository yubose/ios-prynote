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
    let grpcTimeout: TimeInterval = 15
    let host = "testapi2.aitmed.com:443"
    var client: Aitmed_Ecos_V1beta1_EcosAPIServiceClient
    static let shared = AiTmed()
    init() {
        client = Aitmed_Ecos_V1beta1_EcosAPIServiceClient(address: host, secure: true)
        client.timeout = grpcTimeout
    }
    var tmpJWT: String = ""
}
