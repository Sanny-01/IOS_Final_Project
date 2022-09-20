//
//  SignUpModels.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 17.09.22.

import UIKit

enum SignUp
{
    // MARK: Use cases
    
    enum DisplayErrorLabel {
        struct Request { }
        
        struct Response { }
        
        struct ViewModel {
            let errorMessage: String
        }
    }
    
    enum EmptyErrorLabels {
        struct Request { }
        
        struct Response { }
        
        struct ViewModel { }
    }
    
    enum DisplayAlert {
        struct Request { }
        
        struct Response {
            let title: String?
            let errorMessage: String
        }
        
        struct ViewModel {
            let title: String?
            let errorMessage: String
        }
    }
    
    enum Registration {
        struct Request {
            let username: String?
            let email: String?
            let password: String?
            let repeatPassword: String?
        }
        
        struct Response { }
        
        struct ViewModel { }
    }
    
    enum RegisterUser {
        struct Request {
            let email: String
            let password: String
        }
        
        struct Response { }
        
        struct ViewModel { }
    }
    
    enum Success {
        struct Request { }
        
        struct Response { }
        
        struct ViewModel { }
    }
}
