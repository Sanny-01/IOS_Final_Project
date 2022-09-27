//
//  HomeModels.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 19.09.22.

import UIKit

enum Home
{
    // MARK: Use cases
    
    enum GetUserBalance
    {
        struct Request { }
        
        struct Response {
            let balance: UserBalance
        }
        
        struct ViewModel {
            let balance: UserBalance
        }
    }
    
    enum GetExchangeRates
    {
        struct Request { }
        
        struct Response {
            let exchangeRate: ExchangeRates
        }
        
        struct ViewModel {
            let exchangeRate: ExchangeRates
        }
    }
    
    enum TabBarItemTapped
    {
        struct Request {
            let tag: Int
        }
        
        struct Response {
            let tag: Int
        }
        
        struct ViewModel {
            let tag: Int
        }
    }
    
    enum ShowAlert
    {
        struct Request {
            let tag: Int
        }
        
        struct Response {
            let title: String?
            let message: String
        }
        
        struct ViewModel {
            let title: String?
            let message: String
        }
    }
    
    enum HideSpinner
    {
        struct Request { }
        
        struct Response { }
        
        struct ViewModel { }
    }
}
