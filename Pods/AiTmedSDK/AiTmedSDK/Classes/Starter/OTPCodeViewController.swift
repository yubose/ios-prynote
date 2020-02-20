import UIKit
import TYTextField
import PromiseKit

public class OPTCodeViewController: UIViewController {
    
    //MARK: - Views
    private weak var stackView: UIStackView!
    private weak var titleLabel: UILabel!
    private weak var detailLabel: UILabel!
    private weak var codeTextField: TYPinCodeTextField!
    private weak var errorLabel: UILabel!
    private weak var backButton: UIButton!
    private weak var resendButton: TYButton!
    private weak var scrollView: UIScrollView!
    private weak var container: UIView!
    
    //MARK: - Properties
    private let phoneNumber: String
    private let pinCodeCount: UInt = 6
    private let action: (String) -> Void
    private let completion: (() -> Void)?
    private var isErrorOnScreen = false
    private let autoSend: Bool
    private let keyboard = Keyboard()
    private var containerOriginalFrame = CGRect.zero
    
    //MARK: - Initialization
    public init(phoneNumber: String, autoSend: Bool = false, action: @escaping (String) -> Void, completion: (() -> Void)?) {
        self.action = action
        self.phoneNumber = phoneNumber
        self.autoSend = autoSend
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - View lifecycle
    public override func loadView() {
        let sv = UIScrollView()
        self.scrollView = sv
        view = sv
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureViews()
        autoSendIfNeeded()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let _ = codeTextField.becomeFirstResponder()
    }
    
    //MARK: - Actions
    @objc func backButtonTapped() {
        failDismiss()
    }
    
    @objc func resendButtonTapped(button: TYButton) {
        if isErrorOnScreen {
            clearError()
        }
        
        sendOPTCode(to: phoneNumber)
    }
    
    @objc func didTappedOnScrollView() {
        view.endEditing(true)
    }
    
    //MARK: - Other
    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        //quick fix a bug in tytextfield
        let _ = codeTextField.becomeFirstResponder()
    }
    
    //MARK: - Private
    private func autoSendIfNeeded() {
        if autoSend { sendOPTCode(to: phoneNumber) }
    }
    
    private func successDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    private func failDismiss() {
        dismiss(animated: true, completion: completion)
    }
    
    private func displayError(_ msg: String) {
        errorLabel.text = msg
        errorLabel.snp.updateConstraints { (make) in
            make.height.equalTo(20)
        }
        
        UIView.animate(withDuration: 0.17) {
            self.stackView.layoutIfNeeded()
        }
        
        isErrorOnScreen = true
    }

    private func clearError() {
        errorLabel.text = ""
        errorLabel.snp.updateConstraints { (make) in
            make.height.equalTo(0)
        }
        
        UIView.animate(withDuration: 0.17) {
            self.stackView.layoutIfNeeded()
        }
        
        isErrorOnScreen = false
    }
    
    private func sendOPTCode(to phoneNumber: String) {
        resendButton.startAnimating()
        
        firstly { () -> Promise<Void> in
            let args = SendOPTCodeArgs(phoneNumber: phoneNumber)
            return AiTmed.sendOPTCode(args: args)
        }.done(on: .main) { [weak self] (_) in
            self?.resendButton?.endAnimatingImmediately()
            self?.resendButton?.startCountDown(countDown)
        }.catch(on: .main) { [weak self] (_) in
            self?.resendButton?.endAnimatingImmediately()
            self?.displayError("Send Code failed")
        }
    }
    
    private func configureViews() {
        view.backgroundColor = .white
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTappedOnScrollView))
        scrollView.addGestureRecognizer(tap)
        scrollView.alwaysBounceVertical = true
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.setCustomSpacing(0, after: codeTextField)
        
        let close = UIImage(named: "close", in: Bundle.current, compatibleWith: nil)
        backButton.setImage(close, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        titleLabel.text = "Verify your mobile number"
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.ty.avenirNext(bold: .bold, size: 32)
        titleLabel.textColor = UIColor.ty.drakGray
        
        detailLabel.text = "Enter your OPT code here"
        detailLabel.textAlignment = .center
        detailLabel.font = UIFont.ty.avenirNext(bold: .medium, size: 16)
        detailLabel.textColor = UIColor.ty.lightGray
        
        codeTextField.labelText = "Code"
        codeTextField.lineLength = 30
        codeTextField.delegate = self

        resendButton.setTitle("Resend", for: .normal)
        resendButton.setTitleColor(.white, for: .normal)
        resendButton.backgroundColor = themeColor
        resendButton.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)
        resendButton.ty.roundedCorner(with: 6)

        errorLabel.font = UIFont.ty.avenirNext(bold: .regular, size: 12)
        errorLabel.textColor = UIColor.ty.defaultRed
        errorLabel.textAlignment = .left
        
        //Observe keyboard
        observeKeyboard()
    }
    
    private func observeKeyboard() {
        keyboard.observeKeyboardDidShow { [unowned self] (info) in
            if self.isResendButtonBeCovered(distance: 20, keyboardMinY: info.endRect.minY) {
                let rect = self.resendButton.convert(self.resendButton.bounds, to: self.view)
                let kbHeight = info.endRect.height
                self.containerOriginalFrame = self.container.frame
                self.container.frame = CGRect(x: self.container.frame.origin.x,
                                               y: self.container.frame.origin.y,
                                               width: self.container.bounds.width,
                                               height: self.container.bounds.height + kbHeight)
                let kbMinY = info.endRect.minY
                let offset = rect.maxY - kbMinY + 20
                self.scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
        }
        
        keyboard.observeKeyboardWillHide { (info) in
            self.container.frame = self.containerOriginalFrame
            print(self.container.frame)
            self.scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    private func isResendButtonBeCovered(distance: CGFloat, keyboardMinY: CGFloat) -> Bool {
        view.layoutIfNeeded()
        let maxY = resendButton.convert(resendButton.bounds, to: nil).maxY
        return maxY + distance > keyboardMinY
    }

    private func setupViews() {
        let container = UIView()
        self.container = container
        view.addSubview(container)
        
        let stackView = UIStackView()
        self.stackView = stackView
        container.addSubview(stackView)

        let titleLabel = UILabel()
        self.titleLabel = titleLabel
        stackView.addArrangedSubview(titleLabel)

        let detailLabel = UILabel()
        self.detailLabel = detailLabel
        stackView.addArrangedSubview(detailLabel)
        
        let emptyView = UIView()
        stackView.addArrangedSubview(emptyView)

        let codeTextField = TYPinCodeTextField(pinCodeCount: pinCodeCount)
        self.codeTextField = codeTextField
        stackView.addArrangedSubview(codeTextField)
        
        let errorLabel = UILabel()
        self.errorLabel = errorLabel
        stackView.addArrangedSubview(errorLabel)
        
        let resendButton = TYButton()
        self.resendButton = resendButton
        stackView.addArrangedSubview(resendButton)
        
        let backButton = UIButton()
        self.backButton = backButton
        view.addSubview(backButton)

        //--------------------------------------------------
        backButton.snp.makeConstraints { (make) in
            make.right.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.width.height.equalTo(24)
        }
        
        container.snp.makeConstraints { (make) in
            make.edges.width.height.equalToSuperview()
        }

        stackView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(statusBarHeight + 16)
            make.left.right.equalToSuperview().inset(60).priority(.high)
            make.width.lessThanOrEqualTo(300).priority(.required)
            make.height.equalTo(320)
        }
        
        codeTextField.snp.makeConstraints { (make) in
            make.height.equalTo(72)
            make.leading.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.height.equalTo(32)
        }
        
        detailLabel.snp.makeConstraints { (make) in
            make.height.equalTo(20)
        }
        
        errorLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
        }
        
        resendButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        emptyView.snp.contentHuggingVerticalPriority = 249
    }
}

extension OPTCodeViewController: TYTextFieldDelegate {
    public func pinCodeTextFieldDidComplete(_ textField: TYPinCodeTextField) {
        let text = textField.text ?? ""
        action(text)
        successDismiss()
    }
    
    //Todo, update to textfield target action editingChanged
    public func textField(_ textField: TYNormalTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        clearError()
        return true
    }
}
