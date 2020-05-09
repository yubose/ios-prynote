//
//  Notebook.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/7/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import AiTmedSDK

class Notebook {
    var id: Data
    var title: String
    var isEncrypt: Bool = false
    var notes: [Note] = []
    var ctime: Date = Date()
    var mtime: Date = Date()
    var isReady = true
    
    init(_ _notebook: AiTmed._Notebook) {
        self.id = _notebook.id
        self.title = _notebook.title
        self.isEncrypt = _notebook.isEncrypt
        self.ctime = _notebook.ctime
        self.mtime = _notebook.mtime
    }
    
    deinit {
        print("notebook-\(title) has deinit")
    }
    
    func addNote(title: String, content: String, completion: @escaping (Result<Note, AiTmedError>) -> Void) {
        AiTmed.addNote(notebookID: id, title: title, content: content, mediaType: .plain, applicationDataType: .data, isEncrypt: isEncrypt) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let _note):
                let note = Note(id: _note.id, notebook: strongSelf, isEncrypt: _note.isEncrypt, title: _note.title, content: _note.content, isBroken: _note.isBroken, mtime: _note.mtime, ctime: _note.ctime)
                strongSelf.notes.insert(note, at: 0)
                NotificationCenter.default.post(name: .didAddNote, object: self, userInfo: nil)
                completion(.success(note))
            }
        }
    }
    
    func retrieveNotes(completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        self.isReady = false
        AiTmed.retrieveNotes(notebookID: id) { (result) in
            self.isReady = true
            switch result {
            case .failure(let error):
                completion(.failure(error))
                NotificationCenter.default.post(name: .didLoadAllNotesInNotebook, object: self)
            case .success(let _notes):
                let notes = _notes.map { _n in
                    return Note(id: _n.id, notebook: self, isEncrypt: _n.isEncrypt, title: _n.title, content: _n.content, isBroken: _n.isBroken, mtime: _n.mtime, ctime: _n.ctime)
                }
                self.notes = notes
                NotificationCenter.default.post(name: .didLoadAllNotesInNotebook, object: self)
                completion(.success(()))
            }
        }
    }
    
    func deleteNote(id: Data, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        AiTmed.deleteNote(id: id) { [weak self] (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(_):
                self?.notes.removeAll(where: { $0.id == id })
                NotificationCenter.default.post(name: .didRemoveNote, object: self)
                completion(.success(()))
            }
        }
    }
    
    func update(title: String, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        AiTmed.updateNotebook(id: id, title: title, isEncrypt: isEncrypt) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let _notebook):
                self.title = _notebook.title
                self.mtime = _notebook.mtime
                self.title = _notebook.title
                
                Storage.default.sortByTitle()
                NotificationCenter.default.post(name: .didUpdateNotebook, object: self)
                completion(.success(()))
            }
        }
    }
}
