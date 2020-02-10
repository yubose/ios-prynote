//
//  Master.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/7/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit

class MasterController: UIViewController {
    lazy var rootSplit = freshSplitViewController()
    
    var isHorizontallyRegular: Bool {
        return traitCollection.horizontalSizeClass == .regular
    }
    
    lazy var stateCoordinator: StateCoordinator = {
        let coordinator = StateCoordinator()
        coordinator.delegate = self
        return coordinator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        installRootSplit()
        configureRootSplit()
    }
    
    func freshSplitViewController() -> UISplitViewController {
        let split = UISplitViewController()
        let navigation = UINavigationController(rootViewController: NotebookViewController(stateCoordinator))
        split.viewControllers = [navigation, freshPlaceholderViewController()]
        return split
    }
    
    func freshPlaceholderViewController() -> UIViewController {
        return PlaceholderViewController.initWithPlaceholder()
    }
    
    func freshNotesController(with group: NotesGroup) -> NotesViewController {
        let vc = NotesViewController(stateCoordinator, group: group)
        return vc
    }
    
    func freshEditor(notebook: Notebook, mode: EditorViewController.Mode) -> EditorViewController {
        return EditorViewController(stateCoordinator, notebook: notebook, mode: mode)
    }
    
    private func installRootSplit() {
        rootSplit.delegate = self
        rootSplit.preferredDisplayMode = .allVisible
        addChild(rootSplit)
        view.addSubview(rootSplit.view)
        rootSplit.didMove(toParent: self)
        
        let nav = primaryNav(rootSplit)
        nav.navigationBar.prefersLargeTitles = true
        nav.navigationBar.shadowImage = UIImage()
        nav.navigationBar.setBackgroundImage(R.image.paper_light(), for: .default)
        nav.navigationBar.isTranslucent = true
        nav.setToolbarHidden(false, animated: false)
        nav.toolbar.isTranslucent = false
        nav.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        nav.toolbar.setBackgroundImage(R.image.paper_light(), forToolbarPosition: .any, barMetrics: .default)
    }
    
    private func configureRootSplit() {
        if isHorizontallyRegular {
            rootSplit.viewControllers = [masterOfSplit(rootSplit), freshPlaceholderViewController()]
        } else {
            rootSplit.viewControllers = [masterOfSplit(rootSplit)]
        }
    }
    
    private func masterOfSplit(_ split: UISplitViewController) -> UIViewController {
        return split.viewControllers[0]
    }
    
    private func notebookVC() -> NotebookViewController {
        return primaryNav(rootSplit).viewControllers[0] as! NotebookViewController
    }
    
    func primaryNav(_ split: UISplitViewController) -> UINavigationController {
        guard let navigation = split.viewControllers.first as? UINavigationController  else {
            fatalError("Configuration of split view controller error")
        }
        
        return navigation
    }
}

extension MasterController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if secondaryViewController is PlaceholderViewController {
            return true
        }
        
        if let secondNav = secondaryViewController as? UINavigationController,
            let editor = secondNav.topViewController as? EditorViewController {
            let navigation = primaryNav(splitViewController)
            navigation.viewControllers.append(editor)
            return true
        }
        return false
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        let navigation = primaryNav(rootSplit)
        let stack = navigation.viewControllers
        
        //only notebook
        if stack.count == 1 {
            return freshPlaceholderViewController()
        }
        
        //notebook and notes || notebook and notes and editor
        if stack.count == 2 || stack.count == 3 {
            
            if navigation.topViewController is EditorViewController {
                let editor = navigation.popViewController(animated: false)!
                return TransparentNavigationController(rootViewController: editor)
            } else {
                return freshPlaceholderViewController()
            }
        }
        
        return nil
    }
}
