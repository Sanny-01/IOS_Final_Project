//
//  UserCredentials.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 10.09.22.
//

import Foundation

struct UserInfo {
    let username: String
    let email: String
    let id: String
    let GEL: Double
    let USD: Double
    let EUR: Double
    
    init(with dictionary: Dictionary<String, Any>) {
        self.username = dictionary["username"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.id = dictionary["userId"] as? String ?? ""
        self.GEL = Double(dictionary["GEL"] as? String ?? "") ?? 0.00
        self.USD = Double(dictionary["USD"] as? String ?? "") ?? 0.00
        self.EUR = Double(dictionary["EUR"] as? String ?? "") ?? 0.00
    }
}

enum userDefaultKeyNames: String {
    case username = "username"
    case email = "email"
    case userId = "userId"
    case GEL = "GEL"
    case USD = "USD"
    case EUR = "EUR"
}

enum exchangeRateNames: String {
    case GELToUSD = "GELToUSD"
    case GELToEUR = "GELToEUR"
    case GELToGBP = "GELToGBP"
    case USDToEUR = "USDToEUR"
}

enum firebaseDataKeys: String {
    case balanceInGel = "GEL"
    case balanceInUsd = "USD"
    case balanceInEur = "EUR"
}
