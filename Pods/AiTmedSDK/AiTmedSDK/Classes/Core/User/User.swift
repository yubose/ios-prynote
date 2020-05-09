//
//  User.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import PromiseKit

public extension AiTmed {
    //MARK: - Has credential
    static func hasCredential(for phoneNumber: String) -> Bool {
        if let c = shared.c, c.phoneNumber == phoneNumber {
            return true
        } else if let _ = Credential(phoneNumber: phoneNumber) {
            return true
        } else {
            return false
        }
    }
    
    static func hasCredential(for phoneNumber: String) -> Promise<Void> {
        return Promise<Void> { resolver in
            if hasCredential(for: phoneNumber) {
                resolver.fulfill(())
            } else {
                resolver.reject(AiTmedError.credentialFailed(.credentialNeeded))
            }
        }
    }
    
    //MARK: - async, retrieve credential
    static func retrieveCredential(args: RetrieveCredentialArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        guard let name = [AiTmedNameKey.phoneNumber: args.phoneNumber, AiTmedNameKey.OPTCode: args.code].toJSON() else {
            completion(.failure(.internalError(.encodeNameFailed)))
            return
        }
        
        let arguments = CreateEdgeArgs(type: AiTmedType.retrieveCredential, name: name, isEncrypt: false)!
        
        firstly { () -> Promise<Edge> in
            createEdge(args: arguments)
        }.done({ (edge) in
            completion(.success(()))
        }).catch({ (error) in
            completion(.failure(error.toAiTmedError()))
        })
    }
    
    static func retrieveCredential(args: RetrieveCredentialArgs) -> Promise<Void> {
        return Promise<Void> { resolver in
            retrieveCredential(args: args) { result in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(_):
                    resolver.fulfill(())
                }
            }
        }
    }
    
    //MARK: - Log in
    static func login(args: LoginArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        //Is new device?
        guard let c = Credential(phoneNumber: args.phoneNumber) else {
            completion(.failure(.credentialFailed(.credentialNeeded)))
            return
        }
        
        shared.c = c
        let arguments = CreateEdgeArgs(type: AiTmedType.login, name: "", isEncrypt: false, bvid: c.userId, evid: nil)!
        
        guard let sk = shared.e.generateSk(from: c.esk, using: args.password) else {
            completion(.failure(AiTmedError.credentialFailed(.passwordWrong)))
            return
        }
        
        
        
        firstly { () -> Promise<Edge> in
            createEdge(args: arguments)
        }.done({ (edge) in
            shared.c.sk = sk
            completion(.success(()))
        }).catch({ (error) in
            completion(.failure(error.toAiTmedError()))
        })
    }
    
    static func login(args: LoginArgs) -> Promise<Void> {
        return DispatchQueue.global().async(.promise) { () -> Void in
            let c = try Credential(phoneNumber: args.phoneNumber).nilToThrow(AiTmedError.credentialFailed(.credentialNeeded))
            
            shared.c = c
            
            let aeArgs = CreateEdgeArgs(type: AiTmedType.login, name: "", isEncrypt: false, bvid: c.userId, evid: nil)!
            let _ = try createEdge(args: aeArgs).wait()
            
            let rsArgs = RetrieveSingleArgs(id: shared.c.userId)
            let vertex = try retrieveVertex(args: rsArgs).wait()
            
            shared.c.update(esk: vertex.esk)
            
            let sk = try shared.e.generateSk(from: shared.c.esk, using: args.password).nilToThrow(AiTmedError.credentialFailed(.passwordWrong))
            shared.c.sk = sk
        }
    }

    //updated----------------------
    static func unlock(password: String) -> Promise<Void> {
        return DispatchQueue.global().async(.promise) { () -> Void in
            guard let _ = shared.c else {
                throw AiTmedError.credentialFailed(.credentialNeeded)
            }
            try login(args: LoginArgs(phoneNumber: shared.c.phoneNumber, password: password)).wait()
        }
        
    }
    //updated----------------------
    
    //MARK: - Log out and lock
    ///keep credential, but clear sk. so that user can log in without OPT verification
    static func lock() {
        shared.c?.sk = nil
    }
    
    ///remove credential, OPT code required for login again
    static func logout() {
        if let _ = shared.c {
            shared.c.clear()
            shared.c = nil
        }
    }
    
    //MARK: - Create user
    static func createUser(args: CreateUserArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        guard let keyPair = shared.e.generateAKey(),
            let esk = shared.e.generateESKey(from: keyPair.secretKey, using: args.password)?.toData() else {
                completion(.failure(.internalError(.encryptionFailed)))
                return
        }
        
        let pk = keyPair.publicKey.toData()
        let sk = keyPair.secretKey.toData()
        let arguments = CreateVertexArgs(type: AiTmedType.user, tage: args.code, uid: args.phoneNumber, pk: pk, esk: esk, sk: sk)
        
        firstly { () -> Promise<Vertex> in
            createVertex(args: arguments)
        }.then { (vertex) -> Promise<Edge> in
            shared.c.sk = keyPair.secretKey
            
            let dict: [String: Any] = ["title": "root", "description": "", "edit_mode": 7]
            let name = try dict.toJSON().wait()
            let args = try CreateEdgeArgs(type: AiTmedType.root, name: name, isEncrypt: true).nilToThrow(AiTmedError.internalError(.encryptionFailed))
                    
            return createEdge(args: args)
        }.done { (edge) in
            completion(.success(()))
        }.catch { (error) in
            completion(.failure(error.toAiTmedError()))
        }
    }
    
    static func createUser(args: CreateUserArgs) -> Promise<Void> {
        return Promise<Void> { resovler in
            createUser(args: args) { result in
                switch result {
                case .failure(let error):
                    resovler.reject(error)
                case .success(_):
                    resovler.fulfill(())
                }
            }
        }
    }
    
    //MARK: - Delete user
    static func deleteUser(completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        guard let c = shared.c, c.status == .login else {
            completion(.failure(.credentialFailed(.credentialNeeded)))
            return
        }
        
        firstly { () -> Promise<Void> in
            deleteVertex(args: DeleteArgs(id: shared.c.userId))
            }.done { (_) in
                shared.c.clear()
                shared.c = nil
                completion(.success(()))
            }.catch { (error) in
                completion(.failure(error.toAiTmedError()))
        }
    }


    static func deleteUser() -> Promise<Void> {
        return Promise<Void> { resolver in
            deleteUser(completion: { (result) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(_):
                    resolver.fulfill(())
                }
            })
        }
    }
    
    //MARK: - Send verification code
    static func sendOPTCode(args: SendOPTCodeArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        guard let name = [AiTmedNameKey.phoneNumber: args.phoneNumber].toJSON(),
                let args = CreateEdgeArgs(type: AiTmedType.sendOPTCode, name: name, isEncrypt: false) else {
                    completion(.failure(.internalError(.encodeNameFailed)))
            return
        }
        
        firstly { () -> Promise<Edge> in
            createEdge(args: args)
        }.done { (edge) in
            completion(.success(()))
        }.catch { (error) in
            completion(Swift.Result.failure(error.toAiTmedError()))
        }
    }
    
    static func sendOPTCode(args: SendOPTCodeArgs) -> Promise<Void> {
        return Promise<Void> { resolver in
            sendOPTCode(args: args, completion: { (result) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(_):
                    resolver.fulfill(())
                }
            })
        }
    }
    
    static func sendOPTCodeWithCode(args: SendOPTCodeArgs) -> Promise<String> {
        return Promise<String> { resolver in
            guard let name = [AiTmedNameKey.phoneNumber: args.phoneNumber].toJSON(),
                    let args = CreateEdgeArgs(type: AiTmedType.sendOPTCode, name: name, isEncrypt: false) else {
                        resolver.reject(AiTmedError.internalError(.encodeNameFailed))
                        return
            }
            
            firstly { () -> Promise<Edge> in
                createEdge(args: args)
            }.done { (edge) in
                resolver.fulfill(String(edge.tage))
            }.catch { (error) in
                resolver.reject(error.toAiTmedError())
            }
        }
    }
    
    //MARK: - update password
    static func updatePassword(_ password: String) -> Promise<Void> {
        return DispatchQueue.global().async(.promise) { () -> Void in
            //make sure user logged in
            try AiTmed.checkStatus().wait()
            
            //generate new esk
            let sk = shared.c.sk!
            let newESK = shared.e.generateESKey(from: sk, using: password)
            guard let esk = newESK else { throw AiTmedError.internalError(AiTmedError.InternalError.encryptionFailed)}
            
            //update vertex
            let args = UpdateVertexArgs(id: shared.c.userId,
                                        type: AiTmedType.user,
                                        tage: 0,
                                        uid: shared.c.phoneNumber,
                                        pk: shared.c.pk.toData(),
                                        esk: esk.toData(),
                                        sk: shared.c.sk!.toData())
            let vertex = try AiTmed.updateVertex(args: args).wait()
            
            //update local credential
            shared.c.update(esk: vertex.esk)
            return
        }
    }
}
