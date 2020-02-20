//
//  Double.swift
//  BluetoothDemo2
//
//  Created by Yi Tong on 6/10/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

extension Double {
    func round(to digit: Int) -> Double {
        return (self * Double(digit)).rounded() / 100
    }
    
    func formattedElapse() -> String {
        let intValue = Int(self)
        let hours = intValue / 3600
        let minutes = (intValue - hours * 3600) / 60
        let seconds = intValue - hours * 3600 - minutes * 60
        
        if hours < 100 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
}
