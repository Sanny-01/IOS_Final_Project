//
//  SignUpVC.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 31.07.22.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpVC: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    
    var emptyFields = 0
    var passwordsDoNotMatch = false
    var passwordCriteria = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        emptyFields = 0
        
        let checkError =  validateFileds()
        
        // validate fields
        if  checkError != nil  {
            // if passwords do not don't display alert
            if emptyFields == 0 && passwordsDoNotMatch == false {
                showAlertWithOkButton(title: nil, message: checkError!)
            }
        }
        else {
            // we know that fields passed validations so we force unwrap them
            let username = userNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().createUser(withEmail: email, password: password) { result, err in
                if err != nil {
                    
                    if let err = err as NSError? {
                        let errCode = AuthErrorCode(_nsError: err)
                        switch errCode.code {
                        case .emailAlreadyInUse:
                            self.showAlertWithOkButton(title: nil, message: "Email is already registered")
                        case .invalidEmail:
                            self.showAlertWithOkButton(title: nil, message: "Please type a valid email address")
                        default:
                            self.showAlertWithOkButton(title: nil, message: "An error occured")
                        }
                        return
                    }
                    
                } else {
                    
                    // user was created and now we store data to firebase
                    let db = Firestore.firestore()
                    guard let result = result else { return }
                    
                    let gel = Int.random(in: 1...1000)
                    let usd = Int.random(in: 1...100)
                    let eur = Int.random(in: 1...50)
                    
                    let data = ["username": username, "email": email, "userId": result.user.uid, "GEL": "\(gel)", "USD": "\(usd)", "EUR": "\(eur)"]
                    db.collection("users").document(result.user.uid).setData(data) { [ weak self ] error in
                        if error != nil {
                            // ERROR
                            self?.showAlertWithOkButton(title: "Alert", message: "Could not upload data to database")
                        }
                        else {
                            let auth = Auth.auth()
                            do {
                                try auth.signOut()
                            } catch {
                                print("Error")
                            }
                            // SUCCESSFUL
                            _ = self?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func setUpElements() {
        userNameTextField.removeAutoCapitalizeAndCorrection()
        emailTextField.removeAutoCapitalizeAndCorrection()
        passwordTextField.removeAutoCapitalizeAndCorrection()
        repeatPasswordTextField.removeAutoCapitalizeAndCorrection()
    }
    
    func validateFileds() -> String? {
        emptyFields += userNameTextField.validateForEmptiness(errorLabel: usernameLabel)
        emptyFields += emailTextField.validateForEmptiness(errorLabel: emailLabel)
        emptyFields += passwordTextField.validateForEmptiness(errorLabel: passwordLabel)
        emptyFields += repeatPasswordTextField.validateForEmptiness(errorLabel: repeatPasswordLabel)
        
        // check if there is an empty field
        if emptyFields != 0 {
            return "Empty field found"
        }
        
        // TODO: remove foce unwrap she debilo shen
        // can force unwrap because it was checked for emptiness previously
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let repeatPassword = repeatPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // to check if password field was changed and it does not match with repeat password
        checkIfPasswordsMatch(password: password, repeatPassword: repeatPassword)
        
        if passwordsDoNotMatch {
            return "Passwords do not match"
        } else if validatePassword(password: password) == false {
            // check password strength
            return "Password is not strong enough. Make sure it covers at least 3 of these 4 criteria. Must contian at least 1 uppercase, 1 lowercase, 1 symbol and be at least 8 characters long."
        }
        
        return nil
    }
    
    // checking password strength using regex
    func validatePassword(password: String) -> Bool {
        passwordCriteria = 0
        
        let lowercaseExpression = "^(?=.*[a-z]).{8,}$"
        let uppercaseExpression = "^(?=.*[A-Z]).{8,}$"
        let symbolExpression = "^(?=.*[$@$!%*#?&]).{8,}$"
        let numberExpression = "^(?=.*[0-9]).{8,}$"
        
        passwordCriteria += checkPasswordWithExpression(expression: lowercaseExpression, password: password) ? 1 : 0
        passwordCriteria += checkPasswordWithExpression(expression: uppercaseExpression, password: password) ? 1 : 0
        passwordCriteria += checkPasswordWithExpression(expression: symbolExpression, password: password) ? 1 : 0
        passwordCriteria += checkPasswordWithExpression(expression: numberExpression, password: password) ? 1 : 0
        
        // chekcing if at least 3 of these password criteria was met
        return passwordCriteria >= 3 ? true : false
    }
    
    func checkPasswordWithExpression(expression: String, password: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", expression)
        
        return predicate.evaluate(with: password)
    }
    
    // checking repeatPasswordField on each added or deleted character if it matches with passwordField
    @IBAction func didChangeRepeatPassowrd(_ sender: UITextField) {
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? " "
        let repeatPassword = repeatPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? " "
        
        if password != repeatPassword {
            repeatPasswordLabel.text =  Constants.passwordsDoNotMatchMessage
            repeatPasswordLabel.alpha = 1
            passwordsDoNotMatch = true
        } else {
            repeatPasswordLabel.text = Constants.emptyFieldErrorMessage
            repeatPasswordLabel.alpha = 0
            passwordsDoNotMatch = false
        }
    }
    
    func checkIfPasswordsMatch(password: String, repeatPassword: String) {
        if password != repeatPassword {
            passwordsDoNotMatch = true
            repeatPasswordLabel.text = Constants.passwordsDoNotMatchMessage
            repeatPasswordLabel.alpha = 1
        } else {
            passwordsDoNotMatch = false
            repeatPasswordLabel.alpha = 0
        }
    }
}


extension UITextField {
    func validateForEmptiness(errorLabel: UILabel) -> Int {
        let textFieldText = self.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // if textfield is empty
        if textFieldText == "" {
            errorLabel.alpha = 1
            errorLabel.text = Constants.emptyFieldErrorMessage
            
            return 1
        } else {
            // if textfield is not empty check that there is no passwords do not match error
            if errorLabel.text != Constants.passwordsDoNotMatchMessage {
                errorLabel.alpha = 0
            }
            
            return 0
        }
    }
    
    func removeAutoCapitalizeAndCorrection() {
        self.autocorrectionType = UITextAutocorrectionType.no
        self.autocapitalizationType = UITextAutocapitalizationType.none
    }
}
