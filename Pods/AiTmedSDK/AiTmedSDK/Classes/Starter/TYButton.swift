//
//  TYButton.swift
//  Prynote
//
//  Created by Yi Tong on 10/21/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit
import PromiseKit

class TYButton: UIButton {
    private weak var activityIndicator: UIActivityIndicatorView!
    private var originalTitle: String?
    private var originalBackgroundColor: UIColor?
    private var timer: Timer?
    private var isCountingDown = false
    private var startAnimatingTime = Date.distantPast
    
    var isAnimating = false
    var minimalAnimationDuration: TimeInterval = 1
    var delayStopAnimating = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func startAnimating() {
        DispatchQueue.main.async {
            guard !self.isAnimating else { return }
            self.isAnimating = true
            self.startAnimatingTime = Date()
            self.activityIndicator.isHidden = false
            self.activityIndicator.backgroundColor = self.backgroundColor
            self.activityIndicator.startAnimating()
        }
    }
    
    func endAnimating() -> Guarantee<Void> {
        return Guarantee<Void> { resolver in
            if delayStopAnimating {
                let (isWithinDelay, remain) = withinDelay(beginAt: startAnimatingTime, minimal: minimalAnimationDuration)
                if isWithinDelay {
                    DispatchQueue.main.asyncAfter(deadline: .now() + remain) {
                        self.endAnimatingImmediately()
                        resolver(())
                    }
                    return
                }
            }
            
            endAnimatingImmediately()
            resolver(())
        }
    }
    
    private func withinDelay(beginAt start: Date, minimal: TimeInterval) -> (Bool, TimeInterval) {
        let elapse = Date().timeIntervalSince(start)
        if elapse > minimal {
            return (false, 0)
        } else {
            return (true, minimal - elapse)
        }
    }
    
    func endAnimatingImmediately() {
        DispatchQueue.main.async {
            guard self.isAnimating else { return }
            self.isAnimating = false
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    func startCountDown(_ seconds: Int) {
        DispatchQueue.main.async {
            self.isCountingDown = true
            var s = seconds
            
            //save original state
            self.originalTitle = self.currentTitle
            self.originalBackgroundColor = self.backgroundColor
            
            //disable button click
            self.isEnabled = false
            self.backgroundColor = UIColor.ty.lightGray
            
            //set up timer
            self.timer?.invalidate()
            self.timer = nil
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                if s <= 0 {
                    self.stopCountDown()
                    return
                }
                
                self.countDown(s)
                s -= 1
            })
            
            self.timer?.fire()
        }
    }
    
    func stopCountDown() {
        guard isCountingDown else { return }
        DispatchQueue.main.async {
            self.isCountingDown = false
            
            //restore original state
            self.setTitle(self.originalTitle, for: .normal)
            
            //enable button click
            self.isEnabled = true
            self.backgroundColor = self.originalBackgroundColor
            
            //invalidate timer
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    private func countDown(_ second: Int) {
        DispatchQueue.main.async {
            self.setTitle("\(second) seconds", for: .normal)
        }
    }
    
    private func setupViews() {
        let indicator = UIActivityIndicatorView(style: .white)
        indicator.hidesWhenStopped = true
        indicator.layer.zPosition = 10
        addSubview(indicator)
        indicator.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        self.activityIndicator = indicator
    }
}
