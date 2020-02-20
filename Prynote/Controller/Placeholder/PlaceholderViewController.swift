//
//  PlaceholderViewController.swift
//  Prynote3
//
//  Created by tongyi on 12/13/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import UIKit

class PlaceholderViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBAction func didBackButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    static func initWithPlaceholder(_ placeholder: String? = nil, backButtonHidden: Bool = true) -> PlaceholderViewController {
        let instance = R.nib.placeholderViewController(owner: nil)!
        if let placeholder = placeholder {
            instance.placeholderLabel.text = placeholder
        }
        instance.backButton.isHidden = backButtonHidden
        return instance
    }
}
