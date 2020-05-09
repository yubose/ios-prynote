//
//  LockViewController.swift
//  Prynote
//
//  Created by tongyi on 2/18/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit
import AiTmedSDK
import PromiseKit
import TYTextField

class LockViewController: UIViewController {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var instructionLabel: UILabel!
    var timer: Timer?
    var elapse: TimeInterval = 0
    
    lazy var passwordInputView: PasswordInputView = {
        let v = PasswordInputView()
        v.delegate = self
        view.addSubview(v)
        v.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        v.alpha = 0
        v.isHidden = true
        return  v
    }()
    
    @IBAction func didTapHomePageButton(_ sender: UIButton) {
        gotoStarter()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
    
    static func freshLockViewController() -> LockViewController {
        guard let vc = Bundle.main.loadNibNamed(R.nib.lockViewController.name, owner: nil, options: nil)?.first as? LockViewController else {
            fatalError("Config lock viewcontroller error")
        }
        
        return vc
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
        
    @objc func didTapRecognized(tap: UITapGestureRecognizer) {
        hideTimeLabel()
        hideInstructionlabel()
        showPasswordInputView()
    }
    
    @objc func didFireTimer(timer: Timer) {
        timeLabel.text = elapse.formattedElapse()
        elapse += 1
    }
    
    private func hideInstructionlabel() {
        UIView.animate(withDuration: 0.1, animations: {
            self.instructionLabel.alpha = 0
        }) { (_) in
            self.instructionLabel.isHidden = true
        }
    }
    
    private func hideTimeLabel() {
        UIView.animate(withDuration: 0.1, animations: {
            self.timeLabel.alpha = 0
        }) { (_) in
            self.timeLabel.isHidden = true
        }
    }
    
    private func showTimeLabel() {
        timeLabel.isHidden = false
        UIView.animate(withDuration: 0.1) {
            self.timeLabel.alpha = 1
        }
    }
    
    private func showInstructionLabel() {
        instructionLabel.isHidden = false
        UIView.animate(withDuration: 0.1) {
            self.instructionLabel.alpha = 1
        }
    }
    
    private func showPasswordInputView() {
        passwordInputView.isHidden = false
        UIView.animate(withDuration: 0.35) {
            self.passwordInputView.alpha = 1
        }
        
    }
    
    private func hidePasswordInputView() {
        UIView.animate(withDuration: 0.35, animations: {
            self.passwordInputView.alpha = 1
        }) { (_) in
            self.passwordInputView.isHidden = true
        }
    }
    
    private func setup() {
        //label
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 50, weight: .semibold)
        
        //set timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(didFireTimer), userInfo: nil, repeats: true)
        timer?.fire()
        
        //register tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapRecognized))
        view.addGestureRecognizer(tap)
    }
    
    private func initialize() {
        AiTmed.lock()
        modalPresentationStyle = .fullScreen
    }
    
    private func unlock(with password: String) {
        AiTmed.unlock(password: password).done(on: .main) { [weak self] (_) in
            self?.hidePasswordInputView()
            self?.lockImageView.isHighlighted = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                gotoMaster()
            }
        }.catch(on: .main) { [weak self] (error) in
            if let aitmederror = error as? AiTmedError {
                self?.passwordInputView.showError(aitmederror.msg)
            } else {
                self?.passwordInputView.showError("unlock failed")
            }
            
        }
    }
}

extension LockViewController: PasswordInputViewProtocol {
    func didInputPassword(view: PasswordInputView, password: String) {
        unlock(with: password)
    }
    
    func didCloseTapped(view: PasswordInputView) {
        hidePasswordInputView()
        showTimeLabel()
        showInstructionLabel()
    }
}
