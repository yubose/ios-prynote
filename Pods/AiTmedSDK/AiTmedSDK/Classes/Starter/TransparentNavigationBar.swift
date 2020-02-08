//
//  TransparentNavigationBar.swift
//  Example
//
//  Created by tongyi on 2/4/20.
//  Copyright © 2020 tongyi. All rights reserved.
//

import UIKit

class TransparentNavigationBar: UINavigationBar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customize()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func customize() {
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
        isTranslucent = true
    }
}


