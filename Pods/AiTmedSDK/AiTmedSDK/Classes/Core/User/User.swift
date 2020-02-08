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
            completion(.failure(.unkown))
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
        
        guard let sk = shared.e.generateSk(from: c.esk, using: args.password) else {
            completion(.failure(AiTmedError.credentialFailed(.passwordWrong)))
            return
        }
        
        shared.c = c
        let arguments = CreateEdgeArgs(type: AiTmedType.login, name: "", isEncrypt: false, bvid: c.userId, evid: nil)!
        
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
        return Promise<Void> { resovler in
            login(args: args, completion: { (result) in
                switch result {
                case .failure(let error):
                    resovler.reject(error)
                case .success(_):
                    resovler.fulfill(())
                }
            })
        }
    }
    
    //MARK: - Log out
    static func logout() {
        shared.c?.sk = nil
    }
    
    static func clearCredential() {
        shared.c.clear()
        shared.c = nil
    }
    
    //MARK: - Create user
    static func createUser(args: CreateUserArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        guard Validator.password(args.password),
            Validator.phoneNumber(args.phoneNumber) else {
                completion(.failure(.unkown))
                return
        }
        
        guard let keyPair = shared.e.generateAKey(),
            let esk = shared.e.generateESKey(from: keyPair.secretKey, using: args.password)?.toData() else {
                completion(.failure(.unkown))
                return
        }
        
        let pk = keyPair.publicKey.toData()
        let sk = keyPair.secretKey.toData()
        let arguments = CreateVertexArgs(type: AiTmedType.user, tage: args.code, uid: args.phoneNumber, pk: pk, esk: esk, sk: sk)
        
        firstly { () -> Promise<Vertex> in
            createVertex(args: arguments)
        }.done { (edge) in
            shared.c.sk = keyPair.secretKey
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
            completion(.failure(.unkown))
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
}
