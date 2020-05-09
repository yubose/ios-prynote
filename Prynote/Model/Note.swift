//
//  Note.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/7/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import UIKit
import AiTmedSDK

class Note {
    var id: Data
    unowned var notebook: Notebook
    var title: String = ""
    var content: String = ""
    var ctime: Date = Date()
    var mtime: Date = Date()
    var isBroken = false
    var isEncrypt = false
    
    init(id: Data, notebook: Notebook, isEncrypt: Bool, title: String = "", content: String = "", isBroken: Bool = false, mtime: Date = Date(), ctime: Date = Date()) {
        self.isEncrypt = isEncrypt
        self.id = id
        self.notebook = notebook
        self.title = title
        self.content = content
        self.isBroken = isBroken
        self.mtime = mtime
        self.ctime = ctime
    }
        
    deinit {
        print("note-\(title) has deinit")
    }
    
    func update(title: String, content: String, completion: @escaping (Result<Note, AiTmedError>) -> Void) {
        AiTmed.updateNote(id: id, notebookID: notebook.id, title: title, content: content, mediaType: .plain, applicationDataType: .data, isEncrypt: isEncrypt) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let _note):
                strongSelf.id = _note.id
                strongSelf.title = _note.title
                strongSelf.content = _note.content
                strongSelf.ctime = _note.ctime
                strongSelf.mtime = _note.mtime
                strongSelf.isEncrypt = _note.isEncrypt
                strongSelf.isBroken = _note.isBroken
                NotificationCenter.default.post(name: .didUpdateNote, object: strongSelf)
                completion(.success(strongSelf))
            }
        }
    }
}
