//
//  LoginModels.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 16.09.22.


import UIKit

enum Login
{
    // MARK: Use cases
    
    enum ShowRegisterPage {
        struct Request { }
        
        struct Response { }
        
        struct ViewModel { }
    }
    
    enum ProcessLogin {
        struct Request {
            let email: String?
            let password: String?
        }
        
        struct Response { }
        
        struct ViewModel { }
    }
    
    enum AuthorizeLogin {
        struct Request {
            let email: String
            let password: String
        }
        
        struct Response { }
        
        struct ViewModel { }
    }
    
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
    
    enum Success {
        struct Request { }
        
        struct Response { }
        
        struct ViewModel { }
    }
    
    enum Fail {
        struct Request { }
        
        struct Response { }
        
        struct ViewModel {
            let title: String?
            let errorMessage: String
        }
    }
}
