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
        
        configureKeyboard()
        configureRoot()
        return true
    }
    
    private func configureRoot() {
        let starter = StartViewController(_title: "Everything is protected", image: UIImage(named: "icon"))
        starter.delegate = self
        window?.rootViewController = starter
    }
    
    private func configureKeyboard() {
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
    }
}

extension AppDelegate: StarterDelegate {
    func userDidSucceedAuthenticate(vc: StartViewController, method: AuthenticateMethod) {
        print("\(method)")
    }
}

