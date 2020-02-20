//
//  Storeage.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import AiTmedSDK

class Storage {
    static var `default` = Storage()
    var notebooks: [Notebook] = []
    
    private init() {}
    
    func retrieveNotebooks(completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        AiTmed.retrieveNotebooks { [weak self] (result) in
            guard let weakSelf = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let _notebooks):
                weakSelf.notebooks = _notebooks.map { Notebook($0) }
                weakSelf.sortByTitle()
                completion(.success(()))
                weakSelf.notebooks.forEach({ (notebook) in
                    notebook.retrieveNotes(completion: { (result) in
                        switch result {
                        case .failure(let error):
                            print("title: \(error.title), msg: \(error.msg)")
                        case .success(_):
                            print("retrieve notes success")
                        }
                    })
                })
            }
        }
    }
    
    func addNotebook(title: String, isEncrypt: Bool, completion: @escaping (Result<Notebook, AiTmedError>) -> Void) {
        AiTmed.addNotebook(title: title, isEncrypt: isEncrypt) { [weak self] (result) in
            guard let weakSelf = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let _notebook):
                let notebook = Notebook(_notebook)
                weakSelf.notebooks.append(notebook)
                weakSelf.sortByTitle()
                completion(.success(notebook))
            }
        }
    }
    
    func deleteNotebook(notebook: Notebook, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        AiTmed.deleteNotebook(id: notebook.id) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(_):
                self.notebooks.removeAll(where: { $0 === notebook })
                completion(.success(()))
            }
        }
    }
    
    func sortByTitle() {
        notebooks.sort { (n1, n2) -> Bool in
            n1.title.compare(n2.title) == .orderedAscending
        }
    }
}
