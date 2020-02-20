//
//  GRPC.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//
import Foundation
import PromiseKit

class GRPC {
    let cache = Cache<Data, Any>(entryLifetime: Config.cacheLifeTime, maximumEntryCount: Config.cacheMaximumCount)
    
    lazy var client: Aitmed_Ecos_V1beta1_EcosAPIServiceClient = {
        let c = Aitmed_Ecos_V1beta1_EcosAPIServiceClient(address: Config.host, secure: true)
        c.timeout = Config.grpcTimeout
        return c
    }()
    
    ///async, create edge: pass out jwt
    func createEdge(edge: Edge, jwt: String, completion: @escaping (Swift.Result<(Edge, String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_ceReq()
        request.edge = edge.toGRPCEdge()
        request.jwt = jwt
        
        print("create edge name: ", edge.name)
        print("create edge request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.ce(request) { [weak cache] (response, result) in
                guard let response = response else {
                    print("create edge has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.apiResultFailed(.apiNoResponse)))
                    return
                }
                
                print("Create edge response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    let e = Edge(e: response.edge)
                    cache?[e.id] = e
                    completion(.success((e, response.jwt)))
                } else if response.code == 1020 {
                    completion(.failure(.apiResultFailed(.userNotExist)))
                } else if response.code == 112 {
                    completion(.failure(.apiResultFailed(.OPTCodeWrong)))
                } else if response.code == 113 {
                    completion(.failure(.credentialFailed(.JWTExpired(response.jwt))))
                } else {
                    completion(.failure(.apiResultFailed(.unkown(response.error))))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown(error.localizedDescription))))
        }
    }
    
    //promise, create edge: pass out jwt
    func createEdge(edge: Edge, jwt: String) -> Promise<(Edge, String)> {
        return Promise<(Edge, String)> { resolver in
            createEdge(edge: edge, jwt: jwt) { (result) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(let r):
                    resolver.fulfill(r)
                }
            }
        }
    }
    
    ///async, retreive edge
    func retrieveEdges(args: RetrieveArgs, jwt: String, completion: @escaping (Swift.Result<([Edge], String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_rxReq()
        request.id = args.ids
        request.objType = ObjectType.edge.code
        request.jwt = jwt
        request.xfname = args.xfname
        
        if let type = args.type {
            request.type = type
        }
        
        if let maxCount = args.maxCount {
            request.maxcount = maxCount
        }
        
        print("retreive edge request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.re(request) { [weak cache] (response, result) in
                guard let response = response else {
                    print("retrieve edge has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.apiResultFailed(.apiNoResponse)))
                    return
                }
                
                print("retrieve edge response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    let e = response.edge.map(Edge.init)
                    e.forEach { cache?[$0.id] = $0 }
                    completion(.success((e, response.jwt)))
                } else if response.code == 113 {
                    completion(.failure(.credentialFailed(.JWTExpired(response.jwt))))
                } else {
                    completion(.failure(.apiResultFailed(.unkown(response.error))))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown(error.localizedDescription))))
        }
    }
    
    ///promise, retrieve edges
    func retrieveEdges(args: RetrieveArgs, jwt: String) -> Promise<([Edge], String)> {
        return Promise<([Edge], String)> { resolver in
            retrieveEdges(args: args, jwt: jwt) { (result) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(let r):
                    resolver.fulfill(r)
                }
            }
        }
    }
    
    ///async
    func delete(ids: [Data], jwt: String, completion: @escaping (Swift.Result<String, AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_dxReq()
        request.id = ids
        request.jwt = jwt
        
        print("delete request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.dx(request) { [weak cache] (response, result) in
                guard let response = response else {
                    print("delete has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.apiResultFailed(.apiNoResponse)))
                    return
                }
                
                print("delete response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    cache?.removeValues(forKeys: ids)
                    completion(.success(response.jwt))
                } else if response.code == 113 {
                    completion(.failure(.credentialFailed(.JWTExpired(response.jwt))))
                } else {
                    completion(.failure(.apiResultFailed(.unkown(response.error))))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown(error.localizedDescription))))
        }
    }
    
    ///promise delete
    func delete(ids: [Data], jwt: String) -> Promise<(Void, String)> {
        return Promise<(Void, String)> { resolver in
            delete(ids: ids, jwt: jwt) { (result) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(let r):
                    resolver.fulfill(((), r))
                }
            }
        }
    }
    
    ///async, create vertex: pass out jwt
    func createVertex(vertex: Vertex, jwt: String, completion: @escaping (Swift.Result<(Vertex, String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_cvReq()
        request.vertex = vertex.toGRPCVertex()
        request.jwt = jwt
        
        print("create vertex request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.cv(request, completion: { [weak cache] (response, result) in
                guard let response = response else {
                    print("create vertex has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.apiResultFailed(.apiNoResponse)))
                    return
                }
                
                print("create vertex response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    let v = Vertex(v: response.vertex)
                    cache?[vertex: v.id] = v
                    completion(.success((v, response.jwt)))
                } else if response.code == 113 {
                    completion(.failure(.credentialFailed(.JWTExpired(response.jwt))))
                } else {
                    completion(.failure(.apiResultFailed(.unkown(response.error))))
                }
            })
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown(error.localizedDescription))))
        }
    }
    
    ///promise, create vertex
    func creatVertex(vertex: Vertex, jwt: String) -> Promise<(Vertex, String)> {
        return Promise<(Vertex, String)> { resolver in
            createVertex(vertex: vertex, jwt: jwt) { (result) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(let r):
                    resolver.fulfill(r)
                }
            }
        }
    }
    
    ///async, create doc
    func createDoc(doc: Doc, jwt: String, completion: @escaping (Swift.Result<(Doc, String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_cdReq()
        request.doc = doc.toGRPCDoc()
        request.jwt = jwt
        
        print("create doc request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.cd(request, completion: { [weak cache] (response, result) in
                guard let response = response else {
                    print("create doc has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.apiResultFailed(.apiNoResponse)))
                    return
                }
                
                print("create doc response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    let d = Doc(d: response.doc)
                    cache?[doc: d.id] = d
                    completion(.success((d, response.jwt)))
                } else if response.code == 113 {
                    completion(.failure(.credentialFailed(.JWTExpired(response.jwt))))
                } else {
                    completion(.failure(.apiResultFailed(.unkown(response.error))))
                }
            })
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown(error.localizedDescription))))
        }
    }
    
    func createDoc(doc: Doc, jwt: String) -> Promise<(Doc, String)> {
        return Promise<(Doc, String)> { resolver in
            createDoc(doc: doc, jwt: jwt) { (result) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(let r):
                    resolver.fulfill(r)
                }
            }
        }
    }
    
    ///async
    func retrieveDocs(args: RetrieveArgs, jwt: String, completion: @escaping (Swift.Result<([Doc], String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_rxReq()
        request.jwt = jwt
        request.objType = ObjectType.doc.code
        request.id = args.ids
        request.xfname = args.xfname
        
        print("retreive doc request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.rd(request) { [weak cache] (response, result) in
                guard let response = response else {
                    print("retrieve doc has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.apiResultFailed(.apiNoResponse)))
                    return
                }
                
                print("retrieve doc response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    let d = response.doc.map(Doc.init)
                    d.forEach { cache?[doc: $0.id] = $0 }
                    completion(.success((d, response.jwt)))
                } else if response.code == 113 {
                    completion(.failure(.credentialFailed(.JWTExpired(response.jwt))))
                } else {
                    completion(.failure(.apiResultFailed(.unkown(response.error))))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown(error.localizedDescription))))
        }
    }
    
    ///promise, retrieve docs
    func retrieveDocs(args: RetrieveArgs, jwt: String) -> Promise<([Doc], String)> {
        return Promise<([Doc], String)> { resolver in
            retrieveDocs(args: args, jwt: jwt) { (result) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(let r):
                    resolver.fulfill(r)
                }
            }
        }
    }
}
