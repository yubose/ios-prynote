//
//  ProfileViewController.swift
//  Prynote
//
//  Created by tongyi on 2/7/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit
import AiTmedSDK

class ProfileViewController: UIViewController {
    @IBAction func didTapRecognized(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        let placeholder = PlaceholderViewController.initWithPlaceholder("No \(label.text ?? "") now...", backButtonHidden: false)
        present(placeholder, animated: true, completion: nil)
    }
    
    @IBAction func didTapSetting(_ sender: UITapGestureRecognizer) {
        let setting = SettingViewController.freshSettingViewController()
        present(setting, animated: true, completion: nil)
    }
    
    @IBAction func didTapLogout(_ sender: UIButton) {
        self.displayAlert(title: "Log out?", msg: "If log out, verification code will be required for logging in", hasCancel: true, actionTitle: "Yes", style: .destructive) {
            AiTmed.logout()
            gotoStarter()
        }
    }
    
    @IBAction func didTapLock(_ sender: UIButton) {
        dismiss(animated: true) {
            gotoLockScreen()
        }
    }
    
    static func freshProfileController() -> ProfileViewController {
        return Bundle.main.loadNibNamed(R.nib.profileViewController.name, owner: self, options: nil)?.first as! ProfileViewController
    }
}
