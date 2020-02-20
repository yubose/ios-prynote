//
//  SettingViewController.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/29/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import UIKit
import AiTmedSDK

class SettingViewController: UIViewController {
    @IBAction func didTapDeleteAccountButton(_ sender: UIButton) {
        displayAlert(title: "Dangerous!", msg: "Are you sure delete your account?(After deletion, all your information will be erased in our system)", hasCancel: true, actionTitle: "Yes", style: .destructive) {
            sender.startAnimating()
            AiTmed.deleteUser().done { [weak self] (_) in
                sender.endAnimating()
                self?.dismiss(animated: true) {
                    gotoStarter()
                }
            }.catch(on: .main) { [weak self] (error) in
                if let aitmederror = error as? AiTmedError {
                    self?.displayAlert(title: "Delete account failed", msg: aitmederror.msg)
                } else {
                    self?.displayAutoDismissAlert(msg: "Delete account failed")
                }
                
            }
        }
    }
    
    static func freshSettingViewController() -> SettingViewController {
        guard let vc = Bundle.main.loadNibNamed("SettingViewController", owner: nil, options: nil)?.first as? SettingViewController else {
            fatalError("config setting view contrller error")
        }
        
        return  vc
    }
    
    @IBAction func didTapBackButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}
