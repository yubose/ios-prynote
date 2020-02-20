//
//  Edge.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//
import PromiseKit
import Foundation

public extension AiTmed {
    //MARK: - Create
    static func createEdge(args: CreateEdgeArgs) -> Promise<Edge> {
        let jwt: String
        
        if args.type == AiTmedType.sendOPTCode || args.type == AiTmedType.login {//if send verification code, jwt == "", we use login to exchange jwt
            jwt = ""
        } else if args.type == AiTmedType.retrieveCredential {//if retrieve credential, use temporary jwt
            jwt = AiTmed.shared.tmpJWT
        } else {
            jwt = AiTmed.shared.c.jwt
        }
        
        return Promise<Edge> { resolver in
            shared.transform(args: args) { (result) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(let edge):
                    shared.g.createEdge(edge: edge, jwt: jwt, completion: { (result) in
                        switch result {
                        case .failure(let error):
                            resolver.reject(error)
                        case .success(let (edge, jwt)):
                            if args.type == AiTmedType.sendOPTCode {//if send verification code, returned jwt saved in tmpJWT
                                shared.tmpJWT = jwt
                            } else if args.type == AiTmedType.retrieveCredential {//if retrieve credential, save credential
                                guard let dict = edge.name.toJSONDict(),
                                        let phoneNumber = dict[AiTmedNameKey.phoneNumber.rawValue] as? String,
                                        let credential = Credential(json: edge.deat, for: phoneNumber) else {
                                            resolver.reject(AiTmedError.internalError(.dataCorrupted))
                                            return
                                }
                                credential.save()
                                shared.c = credential
                            } else {
                                shared.c.jwt = jwt
                            }
                            resolver.fulfill(edge)
                        }
                    })
                }
            }
        }
    }
    
    //MARK: - Update
    static func updateEdge(args: UpdateEdgeArgs) -> Promise<Edge> {
        return createEdge(args: args)
    }
    
    //MARK: - Retrieve
    ///for convinience, we can retrieve single edge
    static func retrieveEdge(args: RetrieveSingleArgs) -> Promise<Edge> {
        return retrieveEdges(args: args).firstValue
    }
    
    static func retrieveEdges(args: RetrieveArgs) -> Promise<[Edge]> {
        return Promise<[Edge]> { resolver in
            if let error = shared.checkStatus() {
                resolver.reject(error)
                return
            }
            
            shared.g.retrieveEdges(args: args, jwt: shared.c.jwt, completion: { (result) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(let (edges, jwt)):
                    shared.c.jwt = jwt
                    resolver.fulfill(edges)
                }
            })
        }
    }
    
    //MARK: - Delete
    static func deleteEdge(args: DeleteArgs) -> Promise<Void> {
        return Promise<Void> { resolver in
            if let error = shared.checkStatus() {
                resolver.reject(error)
                return
            }
            
            firstly { () -> Promise<[Doc]> in
                retrieveDocs(args: RetrieveArgs(ids: [args.id], xfname: "eid"))
            }.then({ (docs) -> Promise<Void> in
                let deletePromises = docs.map { deleteDocument(args: DeleteArgs(id: $0.id)) }
                return when(fulfilled: deletePromises)
            }).then({ (_) -> Promise<Void> in
                DispatchQueue.global().async(.promise, execute: { () -> Void in
                    let (_, jwt) = try shared.g.delete(ids: [args.id], jwt: shared.c.jwt).wait()
                    shared.c.jwt = jwt
                })
            }).done({ (_) in
                resolver.fulfill(())
            }).catch({ (error) in
                resolver.reject(error)
            })
        }
    }
}

extension AiTmed {
    ///Create and update use same
    func transform(args: CreateEdgeArgs, completion: (Swift.Result<Edge, AiTmedError>) -> Void) {
        var edge = Edge()
        edge.type = args.type
        edge.name = args.name
        edge.stime = args.stime
        
        if let bivd = args.bvid {
            edge.bvid = bivd
        }
        
        if let besak = args.besak {
            edge.besak = besak
        }
        
        if let eesak = args.eesak {
            edge.eesak = eesak
        }
        
        if let arguments = args as? UpdateEdgeArgs {
            edge.id = arguments.id
        }
        
        completion(.success(edge))
    }
}




