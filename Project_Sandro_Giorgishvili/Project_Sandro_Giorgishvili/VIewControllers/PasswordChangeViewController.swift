//
//  PasswordChangeViewController.swift
//  Project_Sandro_Giorgishvili
//
//  Created by sgiorgishvili on 02.08.22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PasswordChangeViewController: UIViewController {
    
    @IBOutlet private weak var currentPasswordTextField: UITextField!
    @IBOutlet private weak var newPasswordTextField: UITextField!
    @IBOutlet private weak var repeatPasswordTextField: UITextField!
    
    @IBOutlet private weak var currentPasswordLabel: UILabel!
    @IBOutlet private weak var newPasswordLabel: UILabel!
    @IBOutlet private weak var repeatPasswordLabel: UILabel!
    
    @IBOutlet private weak var lowercaseLetterCriteriaLabel: UILabel!
    @IBOutlet private weak var uppercaseLetterCriteriaLabel: UILabel!
    @IBOutlet private weak var numberCriteriaLabel: UILabel!
    @IBOutlet private weak var specialCharacterCriteriaLabel: UILabel!
    
    @IBOutlet private weak var currentPasswordErrorLabel: UILabel!
    @IBOutlet private weak var newPasswordErrorLabel: UILabel!
    @IBOutlet private weak var repeatPasswordErrorLabel: UILabel!
    
    var passwordCriteria = 0
    var emptyFields = 0
    var passwordsDoNotMatch = false
    
    let currentPasswordBottomLine = CALayer()
    let newPasswordBottomLine = CALayer()
    let repeatPasswordBottomLine = CALayer()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextFields()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    deinit {
        print("Page was deinitilized!!!!!!!!!!!!!!!!!!!!!!")
    }
    
    //MARK: - Private Methods
    
    func setUpTextFields() {
        setUpTextFieldBottomLine(textField: currentPasswordTextField, bottomLine: currentPasswordBottomLine)
        setUpTextFieldBottomLine(textField: newPasswordTextField, bottomLine: newPasswordBottomLine)
        setUpTextFieldBottomLine(textField: repeatPasswordTextField, bottomLine: repeatPasswordBottomLine)
    }
    
    private func setUpTextFieldBottomLine(textField: UITextField, bottomLine: CALayer) {
        textField.borderStyle = .none
        bottomLine.frame = CGRect(x: 0.0, y: textField.frame.height - 1 , width: textField.frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        
        textField.layer.addSublayer(bottomLine)
        textField.clipsToBounds = true
    }
    
    func changeColor(color: UIColor, bottomLine: CALayer) {
        bottomLine.backgroundColor = color.cgColor
    }
    
    @IBAction func currentPasswordEditingDidBegin(_ sender: UITextField) {
        editingDidBeginActionsOnTextField(textfield: currentPasswordTextField, titleLabel: currentPasswordLabel, textFieldBottomLine: currentPasswordBottomLine)
    }
    
    @IBAction func currentPasswordEditingDidEnd(_ sender: UITextField) {
        editingDidEndActionsOnTextField(textfield: currentPasswordTextField, titleLabel: currentPasswordLabel, textFieldBottomLine: currentPasswordBottomLine, placeholderText: Constants.Placeholder.currentPassword)
    }
    
    @IBAction func newPasswordEditingChanged(_ sender: UITextField) {
        validateNewPassword()
    }
    
    
    @IBAction func newPasswordEditingDidBegin(_ sender: UITextField) {
        editingDidBeginActionsOnTextField(textfield: newPasswordTextField, titleLabel: newPasswordLabel, textFieldBottomLine: newPasswordBottomLine)
    }
    
    
    @IBAction func newPasswordEditingDidEnd(_ sender: UITextField) {
        editingDidEndActionsOnTextField(textfield: newPasswordTextField, titleLabel: newPasswordLabel, textFieldBottomLine: newPasswordBottomLine, placeholderText: Constants.Placeholder.newPassword)
    }
    
    @IBAction func repeatPasswordEditingChanged(_ sender: UITextField) {
        guard let newPassword = newPasswordTextField.text else { return }
        guard let repeatPassword = repeatPasswordTextField.text else { return }
        
        if !validatePasswordsMatching(password: newPassword, repeatPassword: repeatPassword) {
            repeatPasswordErrorLabel.text = Constants.ErrorMessages.passwordsDoNotMatch
        } else {
            repeatPasswordErrorLabel.text = ""
        }
    }
    
    @IBAction func repeatPasswordEditingDidBegin(_ sender: UITextField) {
        editingDidBeginActionsOnTextField(textfield: repeatPasswordTextField, titleLabel: repeatPasswordLabel, textFieldBottomLine: repeatPasswordBottomLine)
    }
    
    @IBAction func repeatPasswordEditingDidEnd(_ sender: UITextField) {
        editingDidEndActionsOnTextField(textfield: repeatPasswordTextField, titleLabel: repeatPasswordLabel, textFieldBottomLine: repeatPasswordBottomLine, placeholderText: Constants.Placeholder.repeatPassword)
    }
    
    private func editingDidBeginActionsOnTextField(textfield: UITextField, titleLabel: UILabel, textFieldBottomLine: CALayer) {
        textfield.placeholder = ""
        titleLabel.alpha = 1
        changeColor(color: .green, bottomLine: textFieldBottomLine)
    }
    
    private func editingDidEndActionsOnTextField(textfield: UITextField, titleLabel: UILabel, textFieldBottomLine: CALayer, placeholderText: String) {
        guard let text = textfield.text else { return }
        changeColor(color: .lightGray, bottomLine: textFieldBottomLine)
        
        if text.isEmpty {
            textfield.placeholder = placeholderText
            titleLabel.alpha = 0
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        makeErrorLabelsEmpty()

        guard let currentPassword = currentPasswordTextField.text else { return }
        guard let newPassword = newPasswordTextField.text else { return }
        guard let repeatPassword = repeatPasswordTextField.text else { return }
        
        let emptinessCheck = validateFieldsForEmptiness(currentPassword: currentPassword, newPassword: newPassword, repeatPasswor: repeatPassword)
        
        if emptinessCheck {
            let requirementsCheck = validatePassword(currentPassword: currentPassword, newPassword: newPassword, repeatPassword: repeatPassword)
            
            if requirementsCheck {
                let user = Auth.auth().currentUser
                guard let email = user?.email else { return }
                
                let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
                
                user?.reauthenticate(with: credential, completion: { (result, error) in
                    if error != nil {
                        if let err = error as NSError? {
                            let errCode = AuthErrorCode(_nsError: err)
                            switch errCode.code {
                            case .wrongPassword:
                                AlertWorker.showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.incorrectPassword, forViewController: self)
                            default:
                                AlertWorker.showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.generalError, forViewController: self)
                            }
                        }
                    } else {
                        Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                            if error != nil {
                                AlertWorker.showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.generalError, forViewController: self)
                            } else {
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                })
            }
        }
    }
    
    private func validateFieldsForEmptiness(currentPassword: String, newPassword: String, repeatPasswor: String) -> Bool {
        var emptyFields = 0
        
        if currentPassword.isEmpty {
            emptyFields += 1
            currentPasswordErrorLabel.text = Constants.ErrorMessages.emptyField
        }
        
        if newPassword.isEmpty {
            emptyFields += 1
            newPasswordErrorLabel.text = Constants.ErrorMessages.emptyField
        }
        
        if repeatPasswor.isEmpty {
            emptyFields += 1
            repeatPasswordErrorLabel.text = Constants.ErrorMessages.emptyField
        }
        
        return emptyFields == 0 ? true : false
    }
    
    private func validatePassword(currentPassword: String, newPassword: String, repeatPassword: String) -> Bool {
        var requirementsPassed = 0
        
        if !validatePasswordsMatching(password: newPassword, repeatPassword: repeatPassword) {
            repeatPasswordErrorLabel.text = Constants.ErrorMessages.passwordsDoNotMatch
            
            return false
        }
        
        if newPassword.count < 8 {
            AlertWorker.showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.passwordCriteriaError, forViewController: self)
            
            return false
        }
        
        requirementsPassed += checkPasswordWithExpression(expression: Constants.Regex.mustContainLowercase, password: newPassword) ? 1 : 0
        requirementsPassed += checkPasswordWithExpression(expression: Constants.Regex.mustContainUppercase, password: newPassword) ? 1 : 0
        requirementsPassed += checkPasswordWithExpression(expression: Constants.Regex.mustContainNumber, password: newPassword) ? 1 : 0
        requirementsPassed += checkPasswordWithExpression(expression: Constants.Regex.mustContainSymbol, password: newPassword) ? 1 : 0
        
        if requirementsPassed < 3 {
            AlertWorker.showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.passwordCriteriaError, forViewController: self)
            
            return false
        }
        
        if currentPassword == newPassword {
            AlertWorker.showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.samePasswords, forViewController: self)
            
            return false
        }
        
        return true
    }
    
    private func validatePasswordsMatching(password: String, repeatPassword: String) -> Bool {
        password == repeatPassword ? true : false
    }
    
    private func validateNewPassword() {
        passwordCriteria = 0
        
        guard let newPassword = newPasswordTextField.text else { return }
        
        passwordCriteria += checkPasswordWithExpression(expression: Constants.Regex.mustContainLowercase, password: newPassword) ? 1 : 0
        lowercaseLetterCriteriaLabel.textColor = checkPasswordWithExpression(expression: Constants.Regex.mustContainLowercase, password: newPassword) ? UIColor.systemBlue : UIColor.systemGray
        
        passwordCriteria += checkPasswordWithExpression(expression: Constants.Regex.mustContainUppercase, password: newPassword) ? 1 : 0
        uppercaseLetterCriteriaLabel.textColor = checkPasswordWithExpression(expression: Constants.Regex.mustContainUppercase, password: newPassword) ? UIColor.systemBlue : UIColor.systemGray
        
        passwordCriteria += checkPasswordWithExpression(expression: Constants.Regex.mustContainSymbol, password: newPassword) ? 1 : 0
        specialCharacterCriteriaLabel.textColor = checkPasswordWithExpression(expression: Constants.Regex.mustContainSymbol, password: newPassword) ? UIColor.systemBlue : UIColor.systemGray
        
        passwordCriteria += checkPasswordWithExpression(expression: Constants.Regex.mustContainNumber, password: newPassword) ? 1 : 0
        numberCriteriaLabel.textColor = checkPasswordWithExpression(expression: Constants.Regex.mustContainNumber, password: newPassword) ? UIColor.systemBlue : UIColor.systemGray
    }
    
    private func checkPasswordWithExpression(expression: String, password: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", expression)
        
        return predicate.evaluate(with: password)
    }
    
    private func makeErrorLabelsEmpty() {
        currentPasswordErrorLabel.text = ""
        newPasswordErrorLabel.text = ""
        repeatPasswordErrorLabel.text = ""
    }
}
