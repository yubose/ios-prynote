import UIKit
import TYTextField
import PromiseKit
import SnapKit

var themeColor: UIColor = UIColor.ty.lightBlue
var countDown = 30

//MARK: - Error
enum StarterError: Error {
    case phoneNumberNotValid
    case passwordFormatNotValid
    case passwordNotMatch
    case userCancelOPTCodeInput
    case retriveCredentialFailed
    case userNotExist(String)
    case unkown
    
    var msg: String {
        switch self {
        case .phoneNumberNotValid:
            return "Invalid phone number"
        case .passwordFormatNotValid:
            return "Invalid password format"
        case .passwordNotMatch:
            return "Password not match"
        case .retriveCredentialFailed:
            return "Retrieve credential error"
        default:
            return "Unkown error"
        }
    }
}

enum Mode: Equatable {
    case initial
    case possible
    case login
    case signin(String)

    static func ==(lhs: Mode, rhs: Mode) -> Bool {
        switch (lhs, rhs) {
        case (Mode.initial, Mode.initial):
            return true
        case (Mode.login, Mode.login):
            return true
        case (Mode.possible, Mode.possible):
            return true
        case (signin(_), signin(_)):
            return true
        default:
            return false
        }
    }
}

//MARK: - StarterDelegate
public protocol StarterDelegate: class {
    func userDidSucceedAuthenticate(vc: StartViewController, method: AuthenticateMethod)
}

public enum AuthenticateMethod {
    case login
    case signin
}

//MARK: - Constant
private enum Constant {
    static let displayStackViewBottom: CGFloat = 180
    static let inputStackViewBottom: CGFloat = 32
}

public class StartViewController: UIViewController {
    
    //MARK: - Views
    weak var displayStackView: UIStackView!
    weak var inputStackView: UIStackView!
    weak var titleLabel: UILabel!
    weak var imageView: UIImageView!
    weak var separator: UIView!
    weak var instructionLabel: UILabel!
    weak var phoneNumberTF: TYPhoneTextField!
    weak var passwordTF: TYPasswordTextField!
    weak var continueButton: TYButton!
    weak var navigationBar: TransparentNavigationBar!
    
    //MARK: - Properties
    private let _title: String
    private let image: UIImage?
    private var mode: Mode = .initial {
        didSet { modeDidChanged(from: oldValue, to: mode) }
    }
    private var initialInputStackConstraints: [Constraint] = []
    private var changedInputStackConstraints: [Constraint] = []
    private var commonInputStackConstraints: [Constraint] = []
    
    public weak var delegate: StarterDelegate?
    
    //MARK: - Initializations
    public init(_title: String, image: UIImage?) {
        self._title = _title
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self._title = ""
        self.image = UIImage()
        super.init(coder: coder)
    }
    
    //MARK: - View lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureViews()
    }
    
    //MARK: - Actions
    @objc func didContinueButtonTapped(button: TYButton) {
        let phoneNumber = phoneNumberTF.phoneNumber
        let password = passwordTF.text ?? ""
        switch mode {
        case .initial:
            mode = .possible
        case .possible:
            DispatchQueue.global().async(.promise) { () -> Void in
                try self.isPhoneNumberValid().wait()
                let hasCredential: Bool = AiTmed.hasCredential(for: phoneNumber)//has credential?
                if hasCredential {
                    self.mode = .login
                    return
                } else {
                    let code = try self.inputOPTCode().wait()//send opt code
                    
                    let rcArgs = RetrieveCredentialArgs(phoneNumber: phoneNumber, code: code)//retrieve credential
                    do {
                        try AiTmed.retrieveCredential(args: rcArgs).wait()
                    } catch {
                        guard let aitmederror = error as? AiTmedError else {
                            throw StarterError.unkown
                        }
                        
                        switch aitmederror {
                        case .apiResultFailed(.userNotExist):
                            throw StarterError.userNotExist(code)
                        default:
                            throw error
                        }
                    }
                    self.mode = .login
                }
            }.catch(on: .main) { (error) in
                if let starterError = error as? StarterError {
                    switch starterError {
                    case .userCancelOPTCodeInput:
                        break
                    case .userNotExist(let code):
                        self.mode = .signin(code)
                    default:
                        self.displayAutoDismissAlert(msg: starterError.msg)
                    }
                } else if let aitmedError = error as? AiTmedError {
                    self.displayAutoDismissAlert(msg: aitmedError.msg)
                } else {
                    self.displayAutoDismissAlert(msg: StarterError.unkown.msg)
                }
            }
        case .login:
            firstly { () -> Guarantee<Void> in
                self.view.endEditing(true)
                self.froze()
                return Guarantee<Void>.value(self.animateContinueButton())
            }.then { (_) -> Promise<Void> in
                DispatchQueue.global().async(.promise) { () -> Void in
                    try self.isPhoneNumberValid().wait()
                    let args = LoginArgs(phoneNumber: phoneNumber, password: password)
                    try AiTmed.login(args: args).wait()
                }
            }.done { (_) in
                self.delegate?.userDidSucceedAuthenticate(vc: self, method: .login)
            }.ensureThen { () -> Guarantee<Void> in
                self.stopAnimateContinueButton()
            }.catch({ (error) in
                if let starterError = error as? StarterError{
                    self.displayAutoDismissAlert(msg: starterError.msg)
                } else if let aitmedError = error as? AiTmedError {
                    self.displayAutoDismissAlert(msg: aitmedError.msg)
                } else {
                    self.displayAutoDismissAlert(msg: StarterError.unkown.msg)
                }
            }).finally {
                self.defroze()
            }
            
        case .signin(let code):
            firstly { () -> Guarantee<Void> in
                self.view.endEditing(true)
                self.froze()
                return Guarantee<Void>.value(self.animateContinueButton())
            }.then { (_) -> Promise<Void> in
                DispatchQueue.global().async(.promise) { () -> Void in
                    guard let int32Code = Int32(code) else { throw StarterError.unkown }

                    try self.isPhoneNumberValid().wait()
                    let args = CreateUserArgs(phoneNumber: phoneNumber, password: password, code: int32Code)
                    try AiTmed.createUser(args: args).wait()
                }
            }.done { (_) in
                self.delegate?.userDidSucceedAuthenticate(vc: self, method: .signin)
            }.ensureThen { () -> Guarantee<Void> in
                self.stopAnimateContinueButton()
            }.catch { (error) in
                if let starterError = error as? StarterError{
                    self.displayAutoDismissAlert(msg: starterError.msg)
                } else if let aitmedError = error as? AiTmedError {
                    self.displayAutoDismissAlert(msg: aitmedError.msg)
                } else {
                    self.displayAutoDismissAlert(msg: StarterError.unkown.msg)
                }
            }.finally {
                self.defroze()
            }
        }
    }
    
    @objc func didBackButtonTapped(button: UIButton) {
        switch mode {
        case .initial:
            break
        case .possible:
            mode = .initial
        case .signin(_), .login:
            mode = .possible
        }
    }
    
    //MARK: - Public
    public func reset() {
        mode = .initial
    }
    
    //MARK: - Private
    private func animateContinueButton() {
        DispatchQueue.main.async {
            self.continueButton.startAnimating()
        }
    }
    
    private func stopAnimateContinueButton() -> Guarantee<Void> {
        return Guarantee<Void> { resovler in
            self.continueButton.endAnimating().done {
                resovler(())
            }
        }
    }
    
    private func inputOPTCode() -> Promise<String> {
        return Promise<String> { [weak self] resovler in
            guard let strongSelf = self else {
                resovler.reject(StarterError.unkown)
                return
            }
            
            DispatchQueue.main.async {
                let phoneNumber = strongSelf.phoneNumberTF.phoneNumber
                let optCodeVC = OPTCodeViewController(phoneNumber: phoneNumber, autoSend: true, action: { (code) in
                    resovler.fulfill(code)
                }) {
                    resovler.reject(StarterError.userCancelOPTCodeInput)
                }
                strongSelf.present(optCodeVC, animated: true, completion: nil)
            }
        }
    }
    
    private func isPhoneNumberValid() -> Promise<Void> {
        return Promise<Void> { resovler in
            DispatchQueue.main.async {
                if self.phoneNumberTF.isValidPhoneNumber {
                    resovler.fulfill(())
                } else {
                    resovler.reject(StarterError.phoneNumberNotValid)
                }
            }
        }
    }
    
    private func modeDidChanged(from oldMode: Mode, to newMode: Mode) {
        guard oldMode != newMode else { return }
        
        DispatchQueue.main.async {
            if oldMode == .initial && newMode == .possible {
                self.respondIntialToPossible()
                return
            }
            
            if oldMode == .possible, case .signin(_) = newMode {
                self.respondPossibleToSignin()
                return
            }
            
            if oldMode == .possible && newMode == .login {
                self.respondPossibleToLogin()
                return
            }
            
            if oldMode == .login && newMode == .possible {
                self.respondLoginOrSigninToPossible()
                return
            }
            
            if case Mode.signin(_) = oldMode, newMode == .possible {
                self.respondLoginOrSigninToPossible()
                return
            }
            
            if newMode == .initial {
                self.respondBackToInitial()
                return
            }
        }
    }
    
    private func respondLoginOrSigninToPossible() {
        shrinkInputStack().done (on: .main) { (_) in
            self.navigationItem.title = ""
            self.passwordTF.text = ""
            let _ = self.firstTextFieldInStack()?.becomeFirstResponder()
        }
    }
    
    private func respondPossibleToLogin() {
        UIView.animate(withDuration: 0.35, animations: {
            self.passwordTF.isHidden = false
            self.passwordTF.alpha = 1
            self.inputStackView.layoutIfNeeded()
        }) { (_) in
            self.navigationItem.title = "Log in"
            self.passwordTF.isSecure = true
            let _ = self.passwordTF.becomeFirstResponder()
        }
    }
    
    private func respondPossibleToSignin() {
        UIView.animate(withDuration: 0.35, animations: {
            self.passwordTF.isHidden = false
            self.passwordTF.alpha = 1
            self.inputStackView.layoutIfNeeded()
        }) { (_) in
            self.navigationItem.title = "Sign in"
            self.passwordTF.isSecure = false
            let _ = self.passwordTF.becomeFirstResponder()
        }
    }
    
    private func respondBackToInitial() {
        when(showDisplayStack(), shiftInputStackToBottom(), hideNavigationBar(animated: true), shrinkInputStack())
        .done(on: .main) { (_) in
            self.view.endEditing(true)
            self.navigationItem.title = ""
            self.phoneNumberTF.text = ""
            self.passwordTF.text = ""
        }
    }
    
    private func respondIntialToPossible() {
        when(hideDisplayStack(), shiftInputStackToTop(), showNavigationBar(animated: true))
        .done(on: .main) { (_) in
            let _ = self.firstTextFieldInStack()?.becomeFirstResponder()
        }
    }
    
    private func firstTextFieldInStack() -> TYNormalTextField? {
        return inputStackView.arrangedSubviews.first(where: {($0 is TYNormalTextField) && (!$0.isHidden)}) as? TYNormalTextField
    }
    
    private func shrinkInputStack() -> Guarantee<Void> {
        UIView.animate(.promise, duration: 0.35) {
            self.passwordTF.isHidden = true
            self.passwordTF.alpha = 0
            self.inputStackView.layoutIfNeeded()
        }.asVoid()
    }
    
    private func showNavigationBar(animated: Bool) -> Guarantee<Void> {
        if navigationBar.isHidden == true {
            navigationBar.isHidden = false
            if animated {
                return UIView.animate(.promise, duration: 0.17) {
                    self.navigationBar.alpha = 1
                }.asVoid()
            } else {
                navigationBar.alpha = 1
            }
        }
        
        return Guarantee<Void>.value(())
    }
    
    private func hideNavigationBar(animated: Bool) -> Guarantee<Void> {
        if navigationBar.isHidden == false {
            navigationBar.isHidden = true
            if animated {
                return UIView.animate(.promise, duration: 0.17) {
                    self.navigationBar.alpha = 0
                }.asVoid()
            } else {
                navigationBar.alpha = 0
            }
        }
        
        return Guarantee<Void>.value(())
    }
    
    private func hideDisplayStack() -> Guarantee<Void> {
        return UIView.animate(.promise, duration: 0.17) {
            self.displayStackView.alpha = 0
        }.asVoid()
    }
    
    private func showDisplayStack() -> Guarantee<Void> {
        return UIView.animate(.promise, duration: 0.35) {
            self.displayStackView.alpha = 1
        }.asVoid()
    }
    
    private func shiftInputStackToTop() -> Guarantee<Void> {
        inputStackView.snp.removeConstraints()
        commonInputStackConstraints.forEach { $0.activate() }
        changedInputStackConstraints.forEach { $0.activate() }
        
        return UIView.animate(.promise, duration: 0.35) {
            self.view.layoutIfNeeded()
        }.asVoid()
    }
    
    private func shiftInputStackToBottom() -> Guarantee<Void> {
        inputStackView.snp.removeConstraints()
        commonInputStackConstraints.forEach { $0.activate() }
        initialInputStackConstraints.forEach { $0.activate() }
        
        return UIView.animate(.promise, duration: 0.35) {
            self.view.layoutIfNeeded()
        }.asVoid()
    }
    
    private func caculateShiftY(for v: UIView) -> CGFloat {
        let sourceOriginForView: CGPoint = v.convert(.zero, to: view)
        view.layoutIfNeeded()
        let destinationOriginForView: CGPoint = CGPoint(x: sourceOriginForView.x, y: navigationBar.frame.maxY + 16)
        return abs(destinationOriginForView.y - sourceOriginForView.y)
    }
    
    //MARK: - Configuration
    private func configureViews() {
        view.backgroundColor = .white
        
        imageView.contentMode = .scaleAspectFill
        
        navigationBar.setItems([navigationItem], animated: false)
        navigationBar.isHidden = true
        navigationBar.alpha = 0
        
        let leftArrow = UIImage(named: "arrow_back", in: Bundle.current, compatibleWith: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftArrow, style: .done, target: self, action: #selector(didBackButtonTapped))
        
        displayStackView.axis = .vertical
        displayStackView.distribution = .equalSpacing
        displayStackView.alignment = .center
        
        titleLabel.text = _title
        titleLabel.font = UIFont.ty.avenirNext(bold: .medium, size: 27)
        
        separator.backgroundColor = .lightGray
        
        instructionLabel.text = "Log in or sign up for free"
        instructionLabel.font = UIFont.ty.avenirNext(bold: .regular, size: 15)
        instructionLabel.textColor = UIColor.lightGray
        
        inputStackView.axis = .vertical
        inputStackView.distribution = .fill
        inputStackView.alignment = .center
        inputStackView.spacing = 20
        
        phoneNumberTF.labelText = "Mobile Number"
        phoneNumberTF.labelFont = UIFont.ty.avenirNext(bold: .medium, size: 17)
        phoneNumberTF.delegate = self
        phoneNumberTF.keyboardType = .numberPad
        phoneNumberTF.textFont = UIFont.ty.avenirNext(bold: .regular, size: 17)
        
        passwordTF.labelText = "Password"
        passwordTF.labelFont = UIFont.ty.avenirNext(bold: .medium, size: 17)
        passwordTF.textFont = UIFont.ty.avenirNext(bold: .regular, size: 17)
        passwordTF.isHidden = true
        passwordTF.alpha = 0
        
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setAttributedTitle(NSAttributedString(string: "Continue", attributes: [.foregroundColor: UIColor.white]), for: .normal)
        continueButton.backgroundColor = themeColor
        continueButton.addTarget(self, action: #selector(didContinueButtonTapped), for: .touchUpInside)
        continueButton.delayStopAnimating = true
        continueButton.minimalAnimationDuration = 0.75
        continueButton.ty.roundedCorner(with: 6)
    }
    
    //MARK: - Setup
    private func setupViews() {
        let displayStackView = UIStackView()
        self.displayStackView = displayStackView
        view.addSubview(displayStackView)
        
        let titleLabel = UILabel()
        self.titleLabel = titleLabel
        displayStackView.addArrangedSubview(titleLabel)
        
        let imageView = UIImageView(image: image)
        self.imageView = imageView
        displayStackView.addArrangedSubview(imageView)
        
        let separator = UIView()
        self.separator = separator
        displayStackView.addArrangedSubview(separator)
        
        let instructionLabel = UILabel()
        self.instructionLabel = instructionLabel
        displayStackView.addArrangedSubview(instructionLabel)
        
        let inputStackView = UIStackView()
        self.inputStackView = inputStackView
        view.addSubview(inputStackView)
        
        let phoneNumberTF = TYPhoneTextField()
        self.phoneNumberTF = phoneNumberTF
        inputStackView.addArrangedSubview(phoneNumberTF)
        
        let passwordTF = TYPasswordTextField()
        self.passwordTF = passwordTF
        inputStackView.addArrangedSubview(passwordTF)
        
        let continueButton = TYButton(type: .system)
        self.continueButton = continueButton
        inputStackView.addArrangedSubview(continueButton)
        
        let navigationBar = TransparentNavigationBar()
        self.navigationBar = navigationBar
        view.addSubview(navigationBar)
        
        displayStackView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(80)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constant.displayStackViewBottom)
        }
        
        separator.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.leading.trailing.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(120).priority(.high)
            make.width.height.greaterThanOrEqualTo(40)
        }
        
        //initial layout
        inputStackView.snp.makeConstraints { (make) in
            let c1 = make.width.lessThanOrEqualTo(500).constraint
            let c2 = make.leading.equalTo(view.safeAreaLayoutGuide).inset(16).priority(998).constraint
            let c3 = make.centerX.equalToSuperview().constraint
            let c4 = make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constant.inputStackViewBottom).constraint
            //左右间距尽可能等于16，但最大不超过500
            c1.activate()
            c2.activate()
            c3.activate()
            c4.activate()
            initialInputStackConstraints.append(c4)
            commonInputStackConstraints.append(contentsOf: [c1, c2, c3])
        }
        
        //changed layout
        inputStackView.snp.prepareConstraints { (make) in
            let c1 = make.top.equalTo(navigationBar.snp.bottom).offset(16).constraint
            changedInputStackConstraints.append(c1)
        }
        
        phoneNumberTF.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60).priority(999)
        }
        
        passwordTF.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60).priority(999)
        }
        
        continueButton.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        navigationBar.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
    }
}

extension StartViewController: TYTextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: TYNormalTextField) -> Bool {
        if mode == .initial { mode = .possible }
        if mode == .login { mode = .possible }
        if case .signin(_) = mode { mode = .possible }
        return true
    }
}
