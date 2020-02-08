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
    static func addNote(folderID: Data, title: String, content: Data, isEncrypt: Bool, completion: @escaping (Swift.Result<_Note, AiTmedError>) -> Void) {
        let isOnServer = content.isEmbedSatisfied
        let isZipped = content.isZipSatisfied
        let args = CreateDocumentArgs(title: title, content: content, applicationDataType: .data, mediaType: .plain, isEncrypt: isEncrypt, folderID: folderID, isOnServer: isOnServer, isZipped: isZipped)

        firstly { () -> Promise<Document> in
            createDocument(args: args)
        }.done { (document) in
            let _note = _Note(id: document.id, title: document.title, content: document.content, mediaType: document.mediaType, isEncrypt: document.type.isEncrypt, ctime: document.ctime, mtime: document.mtime, isBroken: document.isBroken)
            completion(.success(_note))
        }.catch { (error) in
            completion(.failure(error.toAiTmedError()))
        }
    }
    
    static func updateNote(id: Data, notebookID: Data, title: String, content: Data, isEncrypt: Bool, completion: @escaping (Swift.Result<_Note, AiTmedError>) -> Void) {
        let args = UpdateDocumentArgs(id: id, title: title, content: content, applicationDataType: .data, mediaType: .plain, isEncrypt: isEncrypt, folderID: notebookID, isOnServer: true, isZipped: false)
        firstly { () -> Promise<Document> in
            return updateDocument(args: args)
        }.done { (document) -> Void in
            let _note = _Note(id: document.id, title: document.title, content: document.content, mediaType: document.mediaType, isEncrypt: document.type.isEncrypt, ctime: document.ctime, mtime: document.mtime, isBroken: document.isBroken)
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
    
    static func retrieveNotes(notebookID: Data, completion: @escaping (Swift.Result<[_Note], AiTmedError>) -> Void) {
        let args = RetrieveArgs(ids: [notebookID], xfname: "eid")
        firstly {
            AiTmed.retrieveDocuments(args: args)
        }.map { (documents) -> [_Note] in
            return documents.map {
                _Note(id: $0.id, title: $0.title, content: $0.content, mediaType: $0.mediaType, isEncrypt: $0.type.isEncrypt, ctime: $0.ctime, mtime: $0.mtime, isBroken: $0.isBroken)
            }
        }.done { (_notes) in
            completion(.success(_notes))
        }.catch { (error) in
            completion(.failure(error.toAiTmedError()))
        }
    }

    //MARK: - Notebook
    static func addNotebook(title: String, isEncrypt: Bool, completion: @escaping (Swift.Result<_Notebook, AiTmedError>) -> Void) {
        let type = AiTmedType.notebook
        guard let name = [AiTmedNameKey.title: title].toJSON(),
                let args = CreateEdgeArgs(type: type, name: name, isEncrypt: isEncrypt) else {
            completion(.failure(.unkown))
            return
        }
        
        AiTmed.createEdge(args: args)
        .done { (edge) in
            guard let dict = edge.name.toJSONDict(), let title = dict["title"] as? String else {
                completion(.failure(.unkown))
                return
            }
            
            let _notebook = _Notebook(id: edge.id, title: title, isEncrypt: isEncrypt, ctime:
                edge.ctime, mtime: edge.mtime)
            completion(.success(_notebook))
        }.catch { (error) in
            completion(.failure(error.toAiTmedError()))
        }
    }
    
    static func updateNotebook(id: Data, title: String, isEncrypt: Bool, completion: @escaping (Swift.Result<_Notebook, AiTmedError>) -> Void) {
        let type = AiTmedType.notebook
        guard let name = [AiTmedNameKey.title: title].toJSON() else {
            completion(.failure(.unkown))
            return
        }
        
        let args = UpdateEdgeArgs(id: id, type: type, name: name, isEncrypt: isEncrypt)
        
        AiTmed.updateEdge(args: args)
        .done { (edge) in
            guard let dict = edge.name.toJSONDict(), let title = dict["title"] as? String else {
                completion(.failure(.unkown))
                return
            }
            
            let _notebook = _Notebook(id: edge.id, title: title, isEncrypt: !edge.besak.isEmpty, ctime:
                edge.ctime, mtime: edge.mtime)
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
        let type = AiTmedType.notebook
        let args = RetrieveArgs(ids: [], xfname: "bvid", type: type, maxCount: maxCount)
        
        AiTmed.retrieveEdges(args: args)
        .done { (edges) in
            let _notebooks: [_Notebook] = edges.map {
                var title = ""
                if let dict = $0.name.toJSONDict(), let t = dict["title"] as? String {
                    title = t
                }
                return _Notebook(id: $0.id, title: title, isEncrypt: !$0.besak.isEmpty, ctime: $0.ctime, mtime: $0.mtime)
            }
            completion(.success(_notebooks))
        }.catch { (error) in
            completion(.failure(error.toAiTmedError()))
        }
    }
}
