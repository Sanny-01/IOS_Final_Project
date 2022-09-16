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
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTextFields()
        self.hideKeyboardWhenTappedAround()
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
    
    func setUpTextFields() {
        currentPasswordTextField.removeAutoCapitalizeAndCorrection()
        newPasswordTextField.removeAutoCapitalizeAndCorrection()
        repeatPasswordTextField.removeAutoCapitalizeAndCorrection()
        
        setUpTextFieldBottomLine(textField: currentPasswordTextField, bottomLine: currentPasswordBottomLine)
        setUpTextFieldBottomLine(textField: newPasswordTextField, bottomLine: newPasswordBottomLine)
        setUpTextFieldBottomLine(textField: repeatPasswordTextField, bottomLine: repeatPasswordBottomLine)
    }
    
    func setUpTextFieldBottomLine(textField: UITextField, bottomLine: CALayer) {
        textField.borderStyle = .none
        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 2 , width: textField.frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        
        textField.layer.addSublayer(bottomLine)
    }
    
    func changeColor(color: UIColor, bottomLine: CALayer) {
        bottomLine.backgroundColor = color.cgColor
    }
    
    @IBAction func currentPasswordChangeBegin(_ sender: UITextField) {
        currentPasswordTextField.placeholder = " "
        currentPasswordLabel.alpha = 1
        changeColor(color: .green, bottomLine: currentPasswordBottomLine)
    }
    
    @IBAction func currentPasswordChangeEnd(_ sender: UITextField) {
        guard let currentPassword = currentPasswordTextField.text else { return }
        changeColor(color: .lightGray, bottomLine: currentPasswordBottomLine)
        
        // if textfield is empty remove label
        if currentPassword.isEmpty {
            currentPasswordTextField.placeholder = Constants.Placeholder.currentPassword
            currentPasswordLabel.alpha = 0
            
        }
    }
    
    @IBAction func didChangePassword(_ sender: UITextField) {
        validateNewPassword()
    }
    
    @IBAction func newPasswordChangeBegin(_ sender: UITextField) {
        newPasswordTextField.placeholder = " "
        newPasswordLabel.alpha = 1
        changeColor(color: .green, bottomLine: newPasswordBottomLine)
    }
    
    @IBAction func newPasswordChangeEnd(_ sender: UITextField) {
        guard let newPassword = newPasswordTextField.text else { return }
        changeColor(color: .lightGray, bottomLine: newPasswordBottomLine)
        
        // if textfield is empty remove label
        if newPassword.isEmpty {
            newPasswordTextField.placeholder = Constants.Placeholder.newPassword
            newPasswordLabel.alpha = 0
        }
    }
    
    @IBAction func repeatPasswordChangeBegin(_ sender: UITextField) {
        repeatPasswordTextField.placeholder = " "
        repeatPasswordLabel.alpha = 1
        changeColor(color: .green, bottomLine: repeatPasswordBottomLine)
    }
    @IBAction func repeatpasswordChangeEnd(_ sender: UITextField) {
        guard let repeatPassword = repeatPasswordTextField.text else { return }
        changeColor(color: .lightGray, bottomLine: repeatPasswordBottomLine)
        
        // if textfield is empty remove label
        if repeatPassword.isEmpty {
            repeatPasswordTextField.placeholder = Constants.Placeholder.repeatPassword
            repeatPasswordLabel.alpha = 0
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        emptyFields = 0
        dismissKeyboard()
        
        let checkError =  validateFileds()
        
        if checkError != nil {
            if emptyFields == 0 && passwordsDoNotMatch == false {
                showAlertWithOkButton(title: nil, message: checkError!)
            }
        }
        else {
            
            let user = Auth.auth().currentUser
            
            guard let currentPassword = self.currentPasswordTextField.text else { return }
            guard let newPassword = self.newPasswordTextField.text else { return }
            guard let email = user?.email else { return }
            
            let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
            
            user?.reauthenticate(with: credential, completion: { (result, error) in
                if error != nil{
                    self.showAlertWithOkButton(title: "Authorization Error", message: Constants.ErrorMessages.UserRegistration.incorrectPassword)
                }
                else{
                    
                    // check if current password is the same as new one
                    if currentPassword == newPassword {
                        self.showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.UserRegistration.samePasswords)
                    }
                    else {
                        Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                            
                            if error != nil {
                                self.showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.generalError)
                            }
                            else {
                                // move user to home page
                                let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
                                let homeVC = storyboard.instantiateViewController(withIdentifier: "home_page_vc") as? HomePageVC
                                guard let homeVc = homeVC else { return }
                                
                                self.navigationController?.pushViewController(homeVc, animated: false)
                            }
                        }
                    }
                }
            })
        }
    }
    
    // checking password strength using regex
    func validateNewPassword() {
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
    
    func checkPasswordWithExpression(expression: String, password: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", expression)
        
        return predicate.evaluate(with: password)
    }
    
    @IBAction func didChangeRepeatPassword(_ sender: UITextField) {
        guard let password = newPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard let repeatPassword = repeatPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        if password != repeatPassword {
            repeatPasswordErrorLabel.text =  Constants.ErrorMessages.passwordsDoNotMatch
            repeatPasswordErrorLabel.alpha = 1
            passwordsDoNotMatch = true
        } else {
            repeatPasswordErrorLabel.text = Constants.ErrorMessages.emptyField
            repeatPasswordErrorLabel.alpha = 0
            passwordsDoNotMatch = false
        }
    }
    
    func validateFileds() -> String? {
        emptyFields += currentPasswordTextField.validateForEmptiness(errorLabel: currentPasswordErrorLabel)
        emptyFields += newPasswordTextField.validateForEmptiness(errorLabel: newPasswordErrorLabel)
        emptyFields += repeatPasswordTextField.validateForEmptiness(errorLabel: repeatPasswordErrorLabel)
        
        // check if there is an empty field
        if emptyFields != 0 {
            return "Empty field found"
        }
        
        // can force unwrap because it was checked for emptiness previously
        let newPassword = newPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let repeatPassword = repeatPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // to check if password field was changed and it does not match with repeat password
        checkIfPasswordsMatch(password: newPassword, repeatPassword: repeatPassword)
        
        // check password strength
        // TODO: maybe move to function and call after we know that passwords match
        if passwordCriteria < 3 {
            return "Password is not strong enough. Make sure it covers at least 3 of these 4 criteria."
        }
        
        // validate length
        if newPassword.count < 8 {
            return "Passowrd is not long enough"
        }
        
        return nil
    }
    
    func checkIfPasswordsMatch(password: String, repeatPassword: String) {
        if password != repeatPassword {
            passwordsDoNotMatch = true
            repeatPasswordErrorLabel.text = Constants.ErrorMessages.passwordsDoNotMatch
            repeatPasswordErrorLabel.alpha = 1
        } else {
            passwordsDoNotMatch = false
            repeatPasswordErrorLabel.alpha = 0
        }
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlertWithOkButton(title: String?, message: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let titleAttrString = NSMutableAttributedString(string: message, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)
        ])
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.setValue(titleAttrString, forKey:"attributedTitle")
        let action = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(action)
        alertController.view.backgroundColor = UIColor.clear
        self.present(alertController, animated: true)
    }
}
