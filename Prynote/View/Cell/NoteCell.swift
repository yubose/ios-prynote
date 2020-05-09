//
//  NoteCell.swift
//  SplitViewControllerDemo
//
//  Created by Yi Tong on 12/5/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var brokenInstructionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        displayNormalUI()
    }
    
    func displayBrokenUI() {
        brokenInstructionLabel.isHidden = false
        detailLabel.isHidden = true
    }
    
    func displayNormalUI() {
        brokenInstructionLabel.isHidden = true
        detailLabel.isHidden = false
    }
}
