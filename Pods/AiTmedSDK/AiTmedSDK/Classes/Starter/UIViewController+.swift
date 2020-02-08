//
//  UIViewController+.swift
//  Example
//
//  Created by tongyi on 2/3/20.
//  Copyright © 2020 tongyi. All rights reserved.
//
import UIKit
import Foundation

extension UIViewController {
    var  statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    var isVisible: Bool {
        return isViewLoaded && view.window != nil
    }
    
    var topBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height ?? 0)
    }
    
    func displayAutoDismissAlert(msg: String, wait: TimeInterval = 1) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
            self.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func displayInputAlert(title: String?, msg: String?, action: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Enter here"
                textField.textAlignment = .center
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let ok = UIAlertAction(title: "OK", style: .default) { (_) in
                if let text = alert.textFields?[0].text {
                    action(text)
                }
            }
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func displayAlert(title: String?, msg: String?, hasCancel: Bool = false, actionTitle: String? = nil, style: UIAlertAction.Style = .default, action: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            let ok = UIAlertAction(title: actionTitle ?? "OK", style: style) { (_) in
                action?()
            }
            alert.addAction(ok)
            if hasCancel {
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                    
                }
                alert.addAction(cancel)
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func displayAlertSheet(title: String?, msg: String?, hasCancel: Bool, actions: [UIAlertAction]) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .actionSheet)
            actions.forEach { alert.addAction($0) }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

private var ghostViewKey: Void = ()

extension UIViewController {
    private var ghostView: UIView? {
        get {
            return objc_getAssociatedObject(self, &ghostViewKey) as? UIView
        }
        
        set {
            objc_setAssociatedObject(self, &ghostViewKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func froze() {
        DispatchQueue.main.async {
            if self.ghostView == nil {
                let v = UIView()
                v.backgroundColor = .clear
                self.ghostView = v
            }
            
            self.view.addSubview(self.ghostView!)
            self.ghostView!.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func defroze() {
        DispatchQueue.main.async {
            self.ghostView?.removeFromSuperview()
        }
    }
}

