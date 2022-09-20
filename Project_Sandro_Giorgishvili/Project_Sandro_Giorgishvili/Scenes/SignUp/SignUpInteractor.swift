//
//  SignUpInteractor.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 17.09.22.


import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol SignUpBusinessLogic {
    func registerNewUser(request: SignUp.Registration.Request)
}

protocol SignUpDataStore { }

final class SignUpInteractor: SignUpDataStore {
    // MARK: - Clean Components
    var presenter: SignUpPresentationLogic?
    var worker: SignUpWorker?
    
    //MARK: - Private Methods
    
    private func validateFieldsForEmptiness(username: String, email: String, password: String, repeatPassword: String) -> Bool {
        var emptyFields = 0
        
        if username.isEmpty {
            emptyFields += 1
            presenter?.presentEmptyUsernameError(response: SignUp.DisplayErrorLabel.Response())
        }
        
        if email.isEmpty {
            emptyFields += 1
            presenter?.presentEmptyEmailError(response: SignUp.DisplayErrorLabel.Response())
        }
        
        if password.isEmpty {
            emptyFields += 1
            presenter?.presentEmptyPasswordrror(response: SignUp.DisplayErrorLabel.Response())
        }
        
        if repeatPassword.isEmpty {
            emptyFields += 1
            presenter?.presentEmptyRepeatPasswordError(response: SignUp.DisplayErrorLabel.Response())
        }
        
        return emptyFields == 0 ? true : false
    }
    
    private func validatePassword(password: String, repeatPassword: String) -> Bool {
        var requirementsPassed = 0
        
        if !validatePasswordsMatching(password: password, repeatPassword: repeatPassword) {
            presenter?.presentPasswordsNotMatch(response: SignUp.DisplayErrorLabel.Response())
            
            return false
        }
        
        if password.count < 8 {
            presenter?.presentAlertWithMessage(response: SignUp.DisplayAlert.Response(title: nil, errorMessage: Constants.ErrorMessages.passwordCriteriaError))
            
            return false
        }
        
        requirementsPassed += checkPasswordWithExpression(expression: Constants.Regex.mustContainLowercase, password: password) ? 1 : 0
        requirementsPassed += checkPasswordWithExpression(expression: Constants.Regex.mustContainUppercase, password: password) ? 1 : 0
        requirementsPassed += checkPasswordWithExpression(expression: Constants.Regex.mustContainNumber, password: password) ? 1 : 0
        requirementsPassed += checkPasswordWithExpression(expression: Constants.Regex.mustContainSymbol, password: password) ? 1 : 0
        
        if requirementsPassed < 3 {
            presenter?.presentAlertWithMessage(response: SignUp.DisplayAlert.Response(title: nil, errorMessage: Constants.ErrorMessages.passwordCriteriaError))
            
            return false
        }
        
        return true
    }
    
    private func validatePasswordsMatching(password: String, repeatPassword: String) -> Bool {
        password == repeatPassword ? true : false
    }
    
    private func checkPasswordWithExpression(expression: String, password: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", expression)
        
        return predicate.evaluate(with: password)
    }
    
    private func setUsertDataToFirestore(username: String, email: String,result: AuthDataResult) {
        let db = Firestore.firestore()
        
        let gel = Int.random(in: 1...1000)
        let usd = Int.random(in: 1...100)
        let eur = Int.random(in: 1...50)
        
        let data: [String : Any] = [
            UserInformation.firestoreDataKeys.username.rawValue: username,
            UserInformation.firestoreDataKeys.email.rawValue: email,
            UserInformation.firestoreDataKeys.userId.rawValue: result.user.uid,
            UserInformation.firestoreDataKeys.GEL.rawValue: gel,
            UserInformation.firestoreDataKeys.USD.rawValue: usd,
            UserInformation.firestoreDataKeys.EUR.rawValue: eur
        ]
        
        db.collection("users").document(result.user.uid).setData(data) { error in
            if error != nil {
                print("Could not upload dataa to Firebase")
            }
        }
    }
    
    private func signUserOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("User Already Logget Out")
        }
    }
}

extension SignUpInteractor: SignUpBusinessLogic {
    func registerNewUser(request: SignUp.Registration.Request) {
        presenter?.presentEmptyErrorLabels(response: SignUp.EmptyErrorLabels.Response())
        
        guard let username = request.username else { return }
        guard let email = request.email else { return }
        guard let password = request.password else { return }
        guard let repeatPassword = request.repeatPassword else { return }
        
        let emptinessCheck = validateFieldsForEmptiness(username: username, email: email, password: password, repeatPassword: repeatPassword)
        
        if emptinessCheck {
            let requirementsCheck = validatePassword(password: password, repeatPassword: repeatPassword)
            
            if requirementsCheck {
                
                Task {
                    do {
                        let authResult = try await worker?.registerUser(userCredentials: SignUp.RegisterUser.Request(email: email, password: password))
                        
                        guard let result = authResult else { return }
                        setUsertDataToFirestore(username: username, email: email, result: result)
                        
                        signUserOut()
                        
                        presenter?.presentSuccessfullRegistration(response: SignUp.Success.Response())
                    } catch {
                        if let err = error as NSError? {
                            let errCode = AuthErrorCode(_nsError: err)
                            switch errCode.code {
                            case .emailAlreadyInUse:
                                presenter?.presentAlertWithMessage(response: SignUp.DisplayAlert.Response(title: nil, errorMessage: Constants.ErrorMessages.emailAlreadyRegistered))
                            case .invalidEmail:
                                presenter?.presentAlertWithMessage(response: SignUp.DisplayAlert.Response(title: nil, errorMessage: Constants.ErrorMessages.invalidEmailAddress))
                            default:
                                presenter?.presentAlertWithMessage(response: SignUp.DisplayAlert.Response(title: nil, errorMessage: Constants.ErrorMessages.emailAlreadyRegistered))
                            }
                        }
                    }
                }
            }
        }
    }
}
