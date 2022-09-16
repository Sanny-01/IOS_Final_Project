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

enum UserInformation {
    enum firebaseDataKeys: String {
        case GEL = "GEL"
        case USD = "USD"
        case EUR = "EUR"
    }
}
