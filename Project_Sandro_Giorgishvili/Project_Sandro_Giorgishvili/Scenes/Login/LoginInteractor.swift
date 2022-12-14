//
//  LoginInteractor.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 16.09.22.

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol LoginBusinessLogic {
    func processLogin(request: Login.ProcessLogin.Request)
}

protocol LoginDataStore {
    //var name: String { get set }
}

final class LoginInteractor: LoginDataStore {
    
    // MARK: - Clean Components
    
    var presenter: LoginPresentationLogic?
    var worker: LoginWorker?
    
    // MARK: - Priavte Methods
    
    private func validateFieldsForEmptiness(email: String, password: String) -> Bool {
        var emptyFields = 0
        
        if email.isEmpty {
            presenter?.presentEmptyEmailError(response: Login.DisplayErrorLabel.Response())
            emptyFields += 1
        }
        
        if password.isEmpty {
            presenter?.presetnEmptyPasswordError(response: Login.DisplayErrorLabel.Response())
            emptyFields += 1
        }
        
        return emptyFields == 0 ? true : false
    }
}

// MARK: - CountryDetailsBusinessLogic

extension LoginInteractor: LoginBusinessLogic {
    func processLogin(request: Login.ProcessLogin.Request) {
        presenter?.presentEmptyErrorLabels(response: Login.EmptyErrorLabels.Response())
        
        guard let email = request.email else { return }
        guard let password = request.password else { return }
        
        if validateFieldsForEmptiness(email: email, password: password) {
            Task {
                do {
                    let _ = try await worker?.authorizeUser(userCredentials: Login.AuthorizeLogin.Request(email: email, password: password))
                    presenter?.presentSuccessfullLogin(response: Login.Success.Response())
                } catch {
                    presenter?.presentLoginFailed(response: Login.Fail.Response())
                }
            }
        }
    }
}
