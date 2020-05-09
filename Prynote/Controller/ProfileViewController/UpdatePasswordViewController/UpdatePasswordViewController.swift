//
//  UpdatePasswordViewController.swift
//  Prynote
//
//  Created by tongyi on 2/24/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit
import TYTextField
import AiTmedSDK

class UpdatePasswordViewController: UIViewController {
    //MARK: - property
    weak var newPasswordTextField: TYPasswordTextField!
    weak var confirmPasswordTextField: TYPasswordTextField!
    weak var confirmButton: UIButton!
    
    //MARK: - view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    //MARK: - action
    @objc func didTapConfirmButton(button: UIButton) {
        let newPassword = newPasswordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""
        
        guard !newPassword.isEmpty && !confirmPassword.isEmpty else {
                displayAutoDismissAlert(msg: "Password should not be empty")
                return
        }
        
        guard newPassword == confirmPassword else {
            displayAutoDismissAlert(msg: "Two password not match")
            return
        }
        
        view.endEditing(true)
        button.startAnimating()
        AiTmed.updatePassword(newPassword).done(on: .main) { [weak self] (_) in
            self?.displayAlert(title: "Your password has updated", msg: nil)
        }.catch(on: .main) { [weak self] (error) in
            if let aitmederror = error as? AiTmedError {
                self?.displayAutoDismissAlert(msg: "Update password failed \nReason:\(aitmederror.msg)")
            } else {
                self?.displayAutoDismissAlert(msg: "")
            }
        }.finally(on: .main) { [weak self] in
            button.endAnimating()
        }
    }
    
    @objc func didTapDoneItem() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - helper
    private func setUp() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneItem))
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        let newPasswordTextField = TYPasswordTextField()
        newPasswordTextField.labelText = "New password"
        newPasswordTextField.labelFont = UIFont.ty.avenirNext(bold: .medium, size: 17)
        self.newPasswordTextField = newPasswordTextField
        view.addSubview(newPasswordTextField)
        
        let confirmPasswordTextField = TYPasswordTextField()
        confirmPasswordTextField.labelText = "Confirm password"
        confirmPasswordTextField.labelFont = UIFont.ty.avenirNext(bold: .medium, size: 17)
        self.confirmPasswordTextField = confirmPasswordTextField
        view.addSubview(confirmPasswordTextField)
        
        let confirmButton = UIButton(type: .system)
        confirmButton.layer.cornerRadius = 6
        confirmButton.layer.masksToBounds = true
        confirmButton.backgroundColor = UIColor.ty.lightBlue
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.setTitle("Update", for: .normal)
        confirmButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        self.confirmButton = confirmButton
        view.addSubview(confirmButton)
        
        newPasswordTextField.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.height.equalTo(60)
        }
        
        confirmPasswordTextField.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(newPasswordTextField.snp.bottom).offset(16)
            make.height.equalTo(60)
        }
        
        confirmButton.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.top.equalTo(confirmPasswordTextField.snp.bottom).offset(32)
        }
    }
}
