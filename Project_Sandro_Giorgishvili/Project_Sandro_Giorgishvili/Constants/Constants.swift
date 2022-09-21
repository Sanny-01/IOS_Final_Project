//
//  Constants.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 01.08.22.
//

import Foundation

class Constants {
    
    struct Placeholder {
        static let currentPassword = "Current Password"
        static let newPassword = "New Password"
        static let repeatPassword = "Repeat Password"
    }
    
    enum StoryboardIds {
        static let signUpViewController = "SignUpViewController"
        static let homeViewController = "HomeViewController"
        static let profileViewController = "ProfileViewController"
        static let transfersViewController = "TransfersViewController"
        static let loginViewController = "LoginViewController"
        static let passwordChangeViewController = "PasswordChangeViewController"
        static let internalTransfersViewController = "InternalTransfersViewController"
        static let transferToSomeoneViewController = "TransferToSomeoneViewController"
    }
    
    enum StoryBoards {
        static let signUp = "SignUp"
        static let home = "HomePage"
        static let profile = "ProfilePage"
        static let transfers = "TransfersPage"
        static let login = "Main"
        static let passwordChange = "PasswordChange"
        static let internalTransfers = "InternalTransfers"
        static let transferToSomeone = "TransferToSomeone"
    }
    
    enum ErrorMessages {
        static let emptyField = "This field should not be left empty"
        static let passwordsDoNotMatch = "Passwords do not match"
        static let emailAlreadyRegistered = "Email is already registered."
        static let invalidEmailAddress = "Please type a valid email address."
        static let logInError = "Email or password is incorrect. Please, try again."
        static let incorrectPassword = "Password is not correct! Please, try again."
        static let samePasswords = "New password can not be the same as current."
        static let generalError = "An error occured. Please try again later."
        static let passwordCriteriaError = "Password is not strong enough. Make sure it covers at least 3 of these 4 criteria. Must contian at least 1 uppercase, 1 lowercase, 1 symbol and be at least 8 characters long."
        
        enum UserRegistration {
            static let incorrectPassword = "Password is not correct! Please, try again."
            static let samePasswords = "New password can not be the same as current."
        }
        
        enum TransferErrors {
            static let notEnoughMoney = "You do not have enough money on balance."
            static let currienciesNotSelected = "Please select currencies."
            static let sellAmountNotEntered = "Please select amount to sell."
            static let generalError = "Something went wrong. Please, try again later."
            static let incorrectIbanCode = "Could not find a user with given IBAN code."
            static let ownIbanCodeEntered = "You can not add your account as receiver."
            static let transactionProccessFailed = "Could not proccess your transaction. Try again later."
            static let fillRequiredFields = "Please fill required fields."
            static let couldNotGetExchangeRates = "Could not load exchange rates. Please, try again later."
            static let couldNotGetUserBalance = "Could not load user balance. Please, try again later."
        }
    }
    
    enum SuccessMessages {
        enum TransferSuccess {
            static let successfullTransfer = "Successfully transfered."
        }
    }
    
    enum Regex {
        static let mustContainLowercase = "^(?=.*[a-z]).{1,}$"
        static let mustContainUppercase = "^(?=.*[A-Z]).{1,}$"
        static let mustContainSymbol = "^(?=.*[$@$!%*#?&]).{1,}$"
        static let mustContainNumber = "^(?=.*[0-9]).{1,}$"
    }
}
