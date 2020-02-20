//
//  PasswordInputView.swift
//  Prynote
//
//  Created by tongyi on 2/19/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit
import TYTextField
import SnapKit

protocol PasswordInputViewProtocol: class {
    func didInputPassword(view: PasswordInputView, password: String)
    func didCloseTapped(view: PasswordInputView)
}

class PasswordInputView: UIView {
    weak var closeButton: UIButton!
    weak var passwordTextField: TYPasswordTextField!
    weak var errorLabel: UILabel!
    weak var confirmButton: UIButton!
    weak var container: UIView!
    weak var indicator: UIActivityIndicatorView!
    
    weak var delegate: PasswordInputViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func didTapCloseButton(button: UIButton) {
        endEditing(true)
        delegate?.didCloseTapped(view: self)
    }
    
    @objc func didTapConfirmButton(button: UIButton) {
        let password = passwordTextField.text ?? ""
        delegate?.didInputPassword(view: self, password: password)
    }
    
    func showError(_ msg: String) {
        errorLabel.text = msg
    }
    
    func clearError() {
        errorLabel.text = ""
    }
    
    private func setUp() {
        backgroundColor = UIColor(white: 1, alpha: 0.7)
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(R.image.close(), for: .normal)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        self.closeButton = closeButton
        addSubview(closeButton)
                
        let container = UIView()
        self.container = container
        addSubview(container)
        
        let passwordTextField = TYPasswordTextField()
        passwordTextField.labelText = "Password"
        passwordTextField.labelFont = UIFont.ty.avenirNext(bold: .medium, size: 17)
        passwordTextField.textFont = UIFont.ty.avenirNext(bold: .regular, size: 17)
        passwordTextField.delegate = self
        self.passwordTextField = passwordTextField
        container.addSubview(passwordTextField)
        
        let errorLabel = UILabel()
        errorLabel.textColor = UIColor.systemRed
        errorLabel.font = UIFont.ty.avenirNext(bold: .regular, size: 13)
        errorLabel.numberOfLines = 2
        self.errorLabel = errorLabel
        container.addSubview(errorLabel)
        
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("Unlock", for: .normal)
        confirmButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        self.confirmButton = confirmButton
        container.addSubview(confirmButton)

        closeButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-24)
            make.top.equalTo(safeAreaLayoutGuide).offset(16)
            make.height.width.equalTo(24)
        }
        
        container.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(140)
            make.centerY.equalToSuperview()
        }
        
        passwordTextField.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(80)
        }
    
        errorLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(passwordTextField.snp.bottom)
        }
        
        confirmButton.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
    }
}

extension PasswordInputView: TYTextFieldDelegate {
    func textFieldShouldReturn(_ textField: TYNormalTextField) -> Bool {
        delegate?.didInputPassword(view: self, password: textField.text ?? "")
        return true
    }
    
    func textFieldDidChange(_ textField: TYNormalTextField) {
        clearError()
    }
}
