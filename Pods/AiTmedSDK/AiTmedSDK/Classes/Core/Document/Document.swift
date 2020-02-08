//
//  Document.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

public extension AiTmed {
    //MARK: - Create
    static func createDocument(args: CreateDocumentArgs) -> Promise<Document> {
        return DispatchQueue.global().async(.promise, execute: { () -> Document in
            var content = args.content
            
            let _ = try checkStatus().wait()//check status
            print("before zip: ", [UInt8](args.content))
            if args.isZipped {//zip
                content = try zip(args.content).wait()
                print("create zipped:", [UInt8](content))
            }
            
            if args.isEncrypt {//encrypt
                let besak = try besakInEdge(args.folderID).wait()
                let sak = try getSak(besak: besak, sendPK: shared.c.pk, recvSK: shared.c.sk!).wait()
                content = try encrypt(content, sak: sak).wait()
                print("create encrypt:", [UInt8](args.content))
            }
            
            if !args.isBinary {//base64
                content = content.base64EncodedData()
            }
            
            //compose name
            var dict: [String: Any] = ["title": args.title, "type": args.mediaType.rawValue]
            if args.isOnServer {//if data store on server
                dict["data"] = String(bytes: content, encoding: .utf8)
            }
            
            let name = try dict.toJSON().wait()
            
            //create type
            let type = DocumentType.initWithArgs(args: args)
            
            //create doc
            var _doc = Doc()
            _doc.name = name
            _doc.type = Int32(type.value)
            _doc.eid = args.folderID
            _doc.size = Int32(content.count)
            let (doc, jwt) = try shared.g.createDoc(doc: _doc, jwt: shared.c.jwt)
            shared.c.jwt = jwt
            
            if !args.isOnServer {//if the data store on S3
                let deat = try doc.deat.toJSONDict().wait()
                guard let urlString = deat["url"] as? String,
                        let sig = deat["sig"] as? String,
                        let _ = deat["exptime"] as? String else {
                        throw AiTmedError.unkown
                }
                
                //compose upload url: 'url' + ? + 'sig'
                let uploadURL = urlString + "?" + sig
                print("upload url: \(uploadURL)")
                try upload(content, to: uploadURL).wait()
                print("upload success!")
            }
            
            return Document(id: doc.id, folderID: doc.eid, title: args.title, content: args.content, isBroken: false, mediaType: args.mediaType, type: type, mtime: doc.mtime, ctime: doc.ctime)
        })
    }
    
    ///retrieve docs id
    static func retrieveDocs(args: RetrieveArgs) -> Promise<[Doc]> {
        return Promise<[Doc]> { resolver in
            shared.g.retrieveDoc(args: args, jwt: shared.c.jwt, completion: { (result) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(let (docs, jwt)):
                    shared.c.jwt = jwt
                    resolver.fulfill(docs)
                }
            })
        }
    }
    
    static func retrieveDoc(args: RetrieveSingleArgs) -> Promise<Doc> {
        return retrieveDocs(args: args).firstValue
    }
    
    ///retrieve documents using folder id
    static func retrieveDocuments(args: RetrieveArgs) -> Promise<[Document]> {
        return DispatchQueue.global().async(.promise) { () -> [Document] in
            let docs = try retrieveDocs(args: args).wait()
            let documentPromises = docs.map { Document.initWithDoc($0) }
            return try when(fulfilled: documentPromises).wait()
        }
    }
    
    static func retrieveDocument(args: RetrieveSingleArgs) -> Promise<Document> {
        return retrieveDocuments(args: args).firstValue
    }
    
    static func updateDocument(args: UpdateDocumentArgs) -> Promise<Document> {
        return Promise<Document> { resolver in
            firstly { () -> Promise<Void> in
                deleteDocument(args: DeleteArgs(id: args.id))
            }.then { (_) -> Promise<Document> in
                createDocument(args: args)
            }.done { (document) -> Void in
                resolver.fulfill(document)
            }.catch { (error) -> Void in
                resolver.reject(error)
            }
        }
    }
    
    static func deleteDocument(args: DeleteArgs) -> Promise<Void> {
        return Promise<Void> { resolver in
            if let error = shared.checkStatus() {
                resolver.reject(error)
                return
            }
            
            shared.g.delete(ids: [args.id], jwt: shared.c.jwt) { (result: Swift.Result<String, AiTmedError>) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(let jwt):
                    shared.c.jwt = jwt
                    resolver.fulfill(())
                }
            }
        }
    }
}

extension AiTmed {
    ///transform arguments to Doc and processed data(if data not nil means it will be sent to S3)
    ///Doc is used as parament in createDoc function
    ///Data will upload to S3 if isOnServer is false
    func transform(args: CreateDocumentArgs) -> Promise<(Doc, Data)> {
        return Promise<(Doc, Data)> { resolver in
            if let error = checkStatus() {
                resolver.reject(error)
                return
            }
            
            var doc = Doc()
            //firstly, check whether need zip
            var data = args.content
            
            //compose name dict
            var dict: [String: Any] = ["title": args.title, "type": args.mediaType.rawValue]
            
            DispatchQueue.global().async {
                //if zip needed
                if args.isZipped, let zipped = try? data.zip() {
                    data = zipped
                }
                
                //if encrypt, fetch besak
                if args.isEncrypt {
                    let result = AiTmed.beskInEdge(args.folderID)
                    switch result {
                    case .failure(let error):
                        resolver.reject(error)
                        return
                    case .success(let _besak):
                        if let besak = _besak,
                            let sk = self.c.sk,
                            let sak = self.e.generateSAK(xesak: besak, sendPublicKey: self.c.pk, recvSecretKey: sk),
                            let encryptedData = self.e.sKeyEncrypt(secretKey: sak, data: [UInt8](data))  {
                            data = Data(encryptedData)
                            dict["data"] = data.base64EncodedString()
                        } else {
                            resolver.reject(AiTmedError.unkown)
                            return
                        }
                    }
                } else {
                    if args.isOnServer {
                        dict["data"] = data.base64EncodedString()
                    }
                }
                
                guard let name = dict.toJSON() else {
                    resolver.reject(AiTmedError.unkown)
                    return
                }
                
                doc.name = name
                doc.eid = args.folderID//the folder which doc store in
                doc.size = Int32(data.count)//the size of content of doc
                var type = DocumentType(value: 0)
                type.isOnServer = args.isOnServer
                type.isZipped = args.isZipped
                type.isBinary = args.isBinary
                type.isEncrypt = args.isEncrypt
                type.isExtraKeyNeeded = args.isExtraKeyNeeded
                type.isEditable = args.isEditable
                type.applicationDataType = args.applicationDataType
                type.mediaTypeKind = args.mediaType.kind
                doc.type = Int32(type.value)
                resolver.fulfill((doc, data))
            }
        }
    }
}
