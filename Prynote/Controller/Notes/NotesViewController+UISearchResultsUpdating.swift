//
//  NotesViewController+UISearchResultsUpdating.swift
//  Prynote
//
//  Created by tongyi on 2/25/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit

extension NotesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text ?? "")
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredNotes = group.notes.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }
}
