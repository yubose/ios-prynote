//
//  AiTmed+Prynote.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/7/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import PromiseKit

public extension AiTmed {
    //MARK: - Note
    //Updated
    static func addNote(notebookID: Data, title: String, content: String, mediaType: MediaType, applicationDataType: ApplicationDataType, isEncrypt: Bool, completion: @escaping (Swift.Result<_Note, AiTmedError>) -> Void) {
        guard let dataContent = content.data(using: .utf8) else {
            completion(.failure(.internalError(.dataCorrupted)))
            return
        }

        let isZipped = isZipSatisified(for: dataContent, mediaType: mediaType)
        let isOnServer = isOnServerSatisfied(for: dataContent)
        
        let args = CreateDocumentArgs(title: title, content: dataContent, applicationDataType: applicationDataType, mediaType: mediaType, isEncrypt: isEncrypt, folderID: notebookID, isOnServer: isOnServer, isZipped: isZipped)

        firstly { () -> Promise<Document> in
            createDocument(args: args)
        }.done { (document) in
            
            guard let stringContent = String(bytes: document.content, encoding: .utf8) else {
                completion(.failure(.internalError(.dataCorrupted)))
                return
            }
            let _note = _Note(id: document.id, title: document.title, content: stringContent, mediaType: document.mediaType, isEncrypt: document.type.isEncrypt, ctime: document.ctime, mtime: document.mtime, isBroken: document.isBroken)
            completion(.success(_note))
        }.catch { (error) in
            completion(.failure(error.toAiTmedError()))
        }
    }
    
    //Updated
    static func updateNote(id: Data, notebookID: Data, title: String, content: String, mediaType: MediaType, applicationDataType: ApplicationDataType, isEncrypt: Bool, completion: @escaping (Swift.Result<_Note, AiTmedError>) -> Void) {
        
        guard let dataContent = content.data(using: .utf8) else {
            completion(.failure(.internalError(.dataCorrupted)))
            return
        }
        let isZipped = isZipSatisified(for: dataContent, mediaType: mediaType)
        let isOnServer = isOnServerSatisfied(for: dataContent)
        
        
        
        
        let args = UpdateDocumentArgs(id: id, title: title, content: dataContent, applicationDataType: applicationDataType, mediaType: mediaType, isEncrypt: isEncrypt, folderID: notebookID, isOnServer: isOnServer, isZipped: isZipped)
        
        firstly { () -> Promise<Document> in
            return updateDocument(args: args)
        }.done { (document) -> Void in
            guard let stringContent = String(bytes: document.content, encoding: .utf8) else {
                completion(.failure(.internalError(.dataCorrupted)))
                return
            }
            
            let _note = _Note(id: document.id, title: document.title, content: stringContent, mediaType: document.mediaType, isEncrypt: document.type.isEncrypt, ctime: document.ctime, mtime: document.mtime, isBroken: document.isBroken)
            completion(.success(_note))
        }.catch { (error) in
            completion(.failure(error.toAiTmedError()))
        }
    }
    
    static func deleteNote(id: Data, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        firstly { () -> Promise<Void> in
            deleteDocument(args: DeleteArgs(id: id))
        }.done { (_) in
            completion(.success(()))
        }.catch { (error) in
            completion(.failure(error.toAiTmedError()))
        }
    }
    
    //Updated
    static func retrieveNotes(notebookID: Data, completion: @escaping (Swift.Result<[_Note], AiTmedError>) -> Void) {
        let args = RetrieveArgs(ids: [notebookID], xfname: "eid")
        firstly {
            AiTmed.retrieveDocuments(args: args)
        }.map { (documents) -> [_Note] in
            var _notes: [_Note] = []
            
            for document in documents {
                guard let stringContent = String(bytes: document.content, encoding: .utf8) else {
                    _notes.append(_Note(id: document.id, title: document.title, content: "", mediaType: document.mediaType, isEncrypt: document.type.isEncrypt, ctime: document.ctime, mtime: document.mtime, isBroken: true))
                    continue
                }
                
                _notes.append(_Note(id: document.id, title: document.title, content: stringContent, mediaType: document.mediaType, isEncrypt: document.type.isEncrypt, ctime: document.ctime, mtime: document.mtime, isBroken: document.isBroken))
            }
            
            return _notes
        }.done { (_notes) in
            completion(.success(_notes))
        }.catch { (error) in
            completion(.failure(error.toAiTmedError()))
        }
    }

    //MARK: - Notebook
    static func addNotebook(title: String, isEncrypt: Bool, completion: @escaping (Swift.Result<_Notebook, AiTmedError>) -> Void) {
        firstly { () -> Promise<String> in
            return [AiTmedNameKey.title: title].toJSON()
        }.then { (name) -> Promise<Edge> in
            let type = AiTmedType.notebook
            let args = try CreateEdgeArgs(type: type, name: name, isEncrypt: isEncrypt).nilToThrow(AiTmedError.internalError(.encryptionFailed))
            return AiTmed.createEdge(args: args)
        }.then { (edge) -> Promise<_Notebook> in
            let dict = try edge.name.toJSONDict().wait()
            let title = dict["title"] as? String ?? ""
            let _notebook = _Notebook(id: edge.id, title: title, isEncrypt: isEncrypt, ctime:
            edge.ctime, mtime: edge.mtime)
            return Promise<_Notebook>.value(_notebook)
        }.done { (_notebook) in
            completion(.success(_notebook))
        }.catch { (error) in
            completion(.failure(error.toAiTmedError()))
        }
    }
    
    static func updateNotebook(id: Data, title: String, isEncrypt: Bool, completion: @escaping (Swift.Result<_Notebook, AiTmedError>) -> Void) {
        firstly { () -> Promise<String> in
            return [AiTmedNameKey.title: title].toJSON()
        }.then { (name) -> Promise<Edge> in
            let type = AiTmedType.notebook
            let args = try UpdateEdgeArgs(id: id, type: type, name: name, isEncrypt: isEncrypt).nilToThrow(AiTmedError.internalError(.encryptionFailed))
            return AiTmed.updateEdge(args: args)
        }.then { (edge) -> Promise<_Notebook> in
            let dict = try edge.name.toJSONDict().wait()
            let title = dict["title"] as? String ?? ""
            let _notebook = _Notebook(id: edge.id, title: title, isEncrypt: isEncrypt, ctime:
            edge.ctime, mtime: edge.mtime)
            return Promise<_Notebook>.value(_notebook)
        }.done { (_notebook) in
            completion(.success(_notebook))
        }.catch { (error) in
            completion(.failure(error.toAiTmedError()))
        }
    }
    
    static func deleteNotebook(id: Data, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        firstly { () -> Promise<Void> in
            deleteEdge(args: DeleteArgs(id: id))
        }.done({ (_) in
            completion(.success(()))
        }).catch({ (error) in
            completion(.failure(error.toAiTmedError()))
        })
    }
    
    static func retrieveNotebooks(maxCount: Int32? = nil, completion: @escaping (Swift.Result<[_Notebook], AiTmedError>) -> Void) {
        firstly { () -> Promise<[Edge]> in
            let type = AiTmedType.notebook
            let args = RetrieveArgs(ids: [], xfname: "bvid", type: type, maxCount: maxCount)
            return AiTmed.retrieveEdges(args: args)
        }.mapValues { (edge) -> _Notebook in
            let dict = try? edge.name.toJSONDict().wait()
            let title = dict?["title"] as? String ?? ""
            return _Notebook(id: edge.id, title: title, isEncrypt: !edge.besak.isEmpty, ctime: edge.ctime, mtime: edge.mtime)
        }.done { (_notebooks) in
            completion(.success(_notebooks))
        }.catch { (error) in
            completion(.failure(error.toAiTmedError()))
        }
    }
}
