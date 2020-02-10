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
        let note = group.notes[indexPath.row]
        stateCoordinator.select(note)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        
        return group.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = group.notes[indexPath.row]
        let cell: UITableViewCell
        if note.isBroken {
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.Identifier.BROKENNOTECELL, for: indexPath) as! BrokenNoteCell
        } else {
            let _cell = tableView.dequeueReusableCell(withIdentifier: Constant.Identifier.NOTECELL, for: indexPath) as! NoteCell
            configure(_cell, with: note)
            cell = _cell
        }
        
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
            let footer = EmptyFooterView(datasource: self)
            return footer
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = group.notes[indexPath.row]
            WaitingView.scheduleDisplayOnWindow(delay: 0.5, msg: "Deleting...")
            note.notebook.deleteNote(id: note.id) { [weak self] (result) in
                WaitingView.dismissOnWindow()
                guard let strongSelf = self else { return }
                switch result {
                case .failure(let error):
                    strongSelf.displayAutoDismissAlert(msg: "Delete note failed")
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
        cell.detailLabel.text = note.displayContent
        cell.dateLabel.text = note.mtime.formattedDate
    }
}
