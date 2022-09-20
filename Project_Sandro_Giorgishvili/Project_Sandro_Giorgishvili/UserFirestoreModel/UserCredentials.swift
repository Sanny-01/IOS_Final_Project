//
//  UserCredentials.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 10.09.22.
//

import Foundation

struct UserCredentials {
    let username: String
    let email: String
    let id: String
    
    init(with dictionary: Dictionary<String, Any>) {
        self.username = dictionary["username"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.id = dictionary["userId"] as? String ?? ""
    }
}

struct UserBalance {
    let GEL: Double
    let USD: Double
    let EUR: Double
    
    init(with dictionary: Dictionary<String, Any>) {
        self.GEL = dictionary["GEL"] as? Double ?? 0.00
        self.USD = dictionary["USD"] as? Double ?? 0.00
        self.EUR = dictionary["EUR"] as? Double ?? 0.00
    }
}

enum UserInformation {
    enum firestoreDataKeys: String {
        case username = "username"
        case email = "email"
        case userId = "userId"
        case GEL = "GEL"
        case USD = "USD"
        case EUR = "EUR"
    }
}

