//
//  SignUpPresenter.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 17.09.22.

import UIKit

protocol SignUpPresentationLogic {
    func presentEmptyErrorLabels(response: SignUp.EmptyErrorLabels.Response)
    func presentEmptyEmailError(response: SignUp.DisplayErrorLabel.Response)
    func presentEmptyUsernameError(response: SignUp.DisplayErrorLabel.Response)
    func presentEmptyPasswordrror(response: SignUp.DisplayErrorLabel.Response)
    func presentEmptyRepeatPasswordError(response: SignUp.DisplayErrorLabel.Response)
    func presentPasswordsNotMatch(response: SignUp.DisplayErrorLabel.Response)
    func presentAlert(response: SignUp.DisplayAlert.Response)
    func presentSuccessfullRegistration(response: SignUp.Success.Response)
}

final class SignUpPresenter {
    // MARK: - Clean Components
    
    weak var viewController: SignUpDisplayLogic?
}

// MARK: - SignUpPresentationLogic

extension SignUpPresenter: SignUpPresentationLogic {
    func presentSuccessfullRegistration(response: SignUp.Success.Response) {
        viewController?.displaySuccessfullRegistration(ViewModel: SignUp.Success.ViewModel())
    }
    
    func presentPasswordsNotMatch(response: SignUp.DisplayErrorLabel.Response) {
        viewController?.displayPasswordsNotMatch(ViewModel: SignUp.DisplayErrorLabel.ViewModel(errorMessage: Constants.ErrorMessages.passwordsDoNotMatch))
    }
    
    func presentEmptyErrorLabels(response: SignUp.EmptyErrorLabels.Response) {
        viewController?.displayEmptyErrorLabels(ViewModel: SignUp.EmptyErrorLabels.ViewModel())
    }
    
    func presentAlert(response: SignUp.DisplayAlert.Response) {
        viewController?.displayAlert(ViewModel: SignUp.DisplayAlert.ViewModel(title: response.title, errorMessage: response.errorMessage))
    }
    
    func presentEmptyEmailError(response: SignUp.DisplayErrorLabel.Response) {
        viewController?.displayEmptyEmail(ViewModel: SignUp.DisplayErrorLabel.ViewModel(errorMessage: Constants.ErrorMessages.emptyField))
    }
    
    func presentEmptyUsernameError(response: SignUp.DisplayErrorLabel.Response) {
        viewController?.displayEmptyUsername(ViewModel: SignUp.DisplayErrorLabel.ViewModel(errorMessage: Constants.ErrorMessages.emptyField))
    }
    
    func presentEmptyPasswordrror(response: SignUp.DisplayErrorLabel.Response) {
        viewController?.displayEmptyPassword(ViewModel: SignUp.DisplayErrorLabel.ViewModel(errorMessage: Constants.ErrorMessages.emptyField))
    }
    
    func presentEmptyRepeatPasswordError(response: SignUp.DisplayErrorLabel.Response) {
        viewController?.displayEmptyRepeatPassword(ViewModel: SignUp.DisplayErrorLabel.ViewModel(errorMessage: Constants.ErrorMessages.emptyField))
    }
}
