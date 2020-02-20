//
//  AppDelegate.swift
//  Prynote
//
//  Created by Yi Tong on 2/6/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit
import AiTmedSDK
import IQKeyboardManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        configureKeyboard()
        configureToStart()
         return true
    }
    
    func configureToStart() {
        let starter = StartViewController(_title: "Everything is protected", image: UIImage(named: "icon_80"))
        starter.delegate = self
        window?.rootViewController = starter
    }
    
    func configureToMaster() {
        window?.rootViewController = MasterController()
    }
    
    func configureToLockScreen() {
        let lockViewController = LockViewController.freshLockViewController()
        window?.rootViewController = lockViewController
    }
    
    private func configureKeyboard() {
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
    }
}

extension AppDelegate: StarterDelegate {
    func userDidSucceedAuthenticate(vc: StartViewController, method: AuthenticateMethod) {
        if method == .login {
            Storage.default.retrieveNotebooks { (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.window?.rootViewController?.displayAlert(title: error.title, msg: error.msg)
                    }
                case .success(_):
                    DispatchQueue.main.async {
                        self.window?.rootViewController = MasterController()
                    }
                }
            }
        } else {
            window?.rootViewController = MasterController()
        }
    }
}

