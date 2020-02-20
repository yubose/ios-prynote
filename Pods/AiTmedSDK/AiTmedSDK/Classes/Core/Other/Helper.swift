//
//  Helper.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

extension AiTmed {
    //MARK: - Make sure each api call has permission
    func checkStatus() -> AiTmedError? {
        if let c = c {
            if c.status == .login {
                return nil
            } else if c.status == .locked {
                return .credentialFailed(.passwordNeeded)
            }
        }
        
        return .credentialFailed(.signInNeeded)
    }
    
    static func checkStatus() -> Promise<Void> {
        return Promise<Void> { resolver in
            if let c = shared.c {
                if c.status == .login {
                    resolver.fulfill(())
                } else if c.status == .locked {
                    resolver.reject(AiTmedError.credentialFailed(.passwordNeeded))
                }
            }
            
            resolver.reject(AiTmedError.credentialFailed(.signInNeeded))
        }
    }
    
    static func besakInEdge(_ id: Data) -> Promise<Key> {
        return DispatchQueue.global().async(.promise) { () -> Key in
            let edge = try retrieveEdge(args: RetrieveSingleArgs(id: id)).wait()
            
            guard !edge.besak.isEmpty else { throw AiTmedError.credentialFailed(.besakNil) }
            
            return Key(edge.besak)
        }
    }
    
    static func getSak(besak: Key, sendPK: Key, recvSK: Key) -> Promise<Key> {
        return Promise<Key> { resolver in
            if let sak = shared.e.generateSAK(xesak: besak, sendPublicKey: sendPK, recvSecretKey: recvSK) {
                resolver.fulfill(sak)
            } else {
                resolver.reject(AiTmedError.credentialFailed(.eesakNil))
            }
        }
    }
    
    static func zip(_ data: Data) -> Promise<Data> {
        return Promise<Data> { resolver in
            if let zipped = try? data.zip() {
                resolver.fulfill(zipped)
            } else {
                resolver.reject(AiTmedError.internalError(.encryptionFailed))
            }
        }
    }
    
    static func encrypt(_ data: Data, key: Key) -> Promise<Data> {
        return Promise<Data> { resolver in
            if let encryptedData = shared.e.sKeyEncrypt(secretKey: key, data: data.bytes) {
                resolver.fulfill(encryptedData.data)
            } else {
                resolver.reject(AiTmedError.internalError(.encryptionFailed))
            }
        }
    }
    
    static func upload(_ data: Data, to url: URLConvertible) -> Promise<Void> {
        return Promise<Void> { resolver in
            Alamofire.upload(data, to: url, method: .put, headers: nil).response  { (response) in
                guard let statusCode = response.response?.statusCode,
                    (200..<300).contains(statusCode) else {
                        
                        resolver.reject(AiTmedError.apiResultFailed(.uploadFailed))
                        return
                }
                
                resolver.fulfill(())
            }
        }
    }
    
    static func download(from url: URLConvertible) -> Promise<Data> {
        return Promise<Data> { resolver in
            Alamofire.download(url).responseData(completionHandler: { (response) in
                guard let statusCode = response.response?.statusCode,
                    (200..<300).contains(statusCode) else {
                        resolver.reject(AiTmedError.apiResultFailed(.downloadFailed))
                        return
                }
                
                switch response.result {
                case .failure(let error):
                    print(error.localizedDescription)
                    resolver.reject(AiTmedError.apiResultFailed(.downloadFailed))
                case .success(let data):
                    resolver.fulfill(data)
                }
            })
        }
    }
}
