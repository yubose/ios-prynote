//
//  CreateEdgeArgs.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

public class CreateEdgeArgs {
    public var type: Int32
    public var name: String
    public var stime: Int64
    public var bvid: Data?
    public var evid: Data?
    public var besak: Data?
    public var eesak: Data?
    
    public init?(type: Int32, name: String, isEncrypt: Bool, bvid: Data? = nil, evid: Data? = nil) {
        self.type = type
        self.name = name
        self.stime = Int64(Date().timeIntervalSince1970)
        self.bvid = bvid
        
        var besak: Data?
        var eesak: Data?
        
        if isEncrypt {
            guard let c = AiTmed.shared.c, let sk = c.sk, let keyPair = AiTmed.shared.e.generateXESAK(sendSecretKey: sk, recvPublicKey: c.pk) else {
                return nil
            }
            
            besak = keyPair.0.toData()
            eesak = keyPair.1.toData()
        }
        
        self.besak = besak
        self.eesak = eesak
    }
    
    public convenience init(type: Int32, name: String, bvid: Data? = nil, evid: Data? = nil) {
        self.init(type: type, name: name, isEncrypt: false, bvid: bvid, evid: evid)!
    }
}

public class UpdateEdgeArgs: CreateEdgeArgs {
    public let id: Data
    ///isEncrypt must be same as before
    public init(id: Data, type: Int32, name: String, isEncrypt: Bool, bvid: Data? = nil, evid: Data? = nil) {
        self.id = id
        super.init(type: type, name: name, isEncrypt: isEncrypt, bvid: bvid, evid: evid)!
    }
}
