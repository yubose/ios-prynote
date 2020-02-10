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
        displayAutoDismissAlert(msg: "Not implement yet")
    }
    
    @IBAction func didTapLogout(_ sender: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        AiTmed.logout()
        appDelegate.configureToStart()
    }
    
    static func freshProfileController() -> ProfileViewController {
        return Bundle.main.loadNibNamed(R.nib.profileViewController.name, owner: self, options: nil)?.first as! ProfileViewController
    }
}
