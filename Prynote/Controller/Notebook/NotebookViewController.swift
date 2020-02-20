//
//  NotebookViewController.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit
import AiTmedSDK
import SideMenu

class NotebookViewController: UITableViewController {
    let stateCoordinator: StateCoordinator
    var open: Bool = true
    
    init(_ stateCoordinator: StateCoordinator) {
        self.stateCoordinator = stateCoordinator
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    //MARK: - Action
    @objc func didPullToRefreshing(refreshControl: UIRefreshControl) {
        Storage.default.retrieveNotebooks { [weak self] (result) in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async {
                refreshControl.endRefreshing()
            }
            
            switch result {
            case .failure(let error):
                weakSelf.displayAutoDismissAlert(msg: "Operation failed\nReason: \(error.msg)")
            case .success(_):
                DispatchQueue.main.async {
                    weakSelf.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func didTapSetting() {
        let profileController = ProfileViewController.freshProfileController()
        profileController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.arrow_right_circle(), style: .done, target: self, action: #selector(didTapRightItemInProile))
        let profileMenu = SideMenuNavigationController(rootViewController: profileController)
        profileMenu.leftSide = true
        profileMenu.presentationStyle.backgroundColor = .white
        profileMenu.navigationBar.setBackgroundImage(UIImage(), for: .default)
        profileMenu.navigationBar.shadowImage = UIImage()
        profileMenu.navigationBar.isTranslucent = true
        present(profileMenu, animated: true, completion: nil)
    }
    
    @objc func didTapAdd() {
        displayEditingController(with: .create)
    }
    
    @objc func didLoadAllNotesInNotebook(no: Notification) {
        guard let notebook = no.object as? Notebook else { return }
        
        asyncReloadIfNeeded(indexPath(of: .all))
        asyncReloadIfNeeded(indexPath(of: .single(notebook)))
    }
    
    @objc func didRemoveNote(no: Notification) {
        guard let notebook = no.object as? Notebook else { return }
        
        asyncReloadIfNeeded(indexPath(of: .all))
        asyncReloadIfNeeded(indexPath(of: .single(notebook)))
    }
    
    @objc func didTapRightItemInProile() {
        dismiss(animated: true, completion: nil)
    }
}
