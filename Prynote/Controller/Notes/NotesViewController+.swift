//
//  NotesViewController+.swift
//  Prynote3
//
//  Created by tongyi on 12/14/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import UIKit

extension NotesViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note: Note
        
        if isFiltering {
            note = filteredNotes[indexPath.row]
        } else {
            note = group.notes[indexPath.row]
        }
        
        if note.isBroken == true {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            stateCoordinator.select(note)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredNotes.count
        } else {
            return group.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note: Note
        
        if isFiltering {
            note = filteredNotes[indexPath.row]
        } else {
            note = group.notes[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Identifier.NOTECELL, for: indexPath) as! NoteCell
        configure(cell, with: note)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return tableView.bounds.height
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            if isFiltering {
                let label = UILabel()
                label.attributedText = NSAttributedString(string: "No note found", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 27, weight: .medium)])
                label.textAlignment = .center
                return label
            } else {
                let footer = EmptyFooterView(datasource: self)
                return footer
            }
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note: Note
            
            if isFiltering {
                note = filteredNotes[indexPath.row]
            } else {
                note = group.notes[indexPath.row]
            }
            
            WaitingView.scheduleDisplayOnWindow(delay: 0.5, msg: "Deleting...")
            note.notebook.deleteNote(id: note.id) { [weak self] (result) in
                WaitingView.dismissOnWindow()
                guard let strongSelf = self else { return }
                switch result {
                case .failure(let error):
                    strongSelf.displayAutoDismissAlert(msg: "Delete note failed\nReason: \(error.msg)")
                case .success(_):
                    DispatchQueue.main.async {
                        if strongSelf.isCurrentNoteDeleted(deletedID: note.id) {
                            strongSelf.stateCoordinator.select(nil)
                        }
                    }
                }
            }
        }
    }
    
    private func isCurrentNoteDeleted(deletedID: Data) -> Bool {
        if let split = splitViewController,
            split.viewControllers.count > 1,
            let secondNav = split.viewControllers[1] as? UINavigationController,
            let editor = secondNav.topViewController as? EditorViewController,
            case let .update(n) = editor.mode,
            n.id == deletedID {
            return true
        }
        
        return false
    }
    
    private func configure(_ cell: NoteCell, with note: Note) {
        cell.titleLabel.text = note.title
        cell.dateLabel.text = note.mtime.elapseDateString()
        
        if note.isBroken {
            cell.displayBrokenUI()
        } else {
            cell.displayNormalUI()
            cell.detailLabel.text = note.content
        }
    }
}
