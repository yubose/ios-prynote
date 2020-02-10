//
//  TransparentNavigationController.swift
//  Prynote
//
//  Created by tongyi on 2/9/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit

class TransparentNavigationController: UINavigationController {
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        customize()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nil)
        
        customize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        customize()
    }
    
    private func customize() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolbar.isTranslucent = true
    }
}
