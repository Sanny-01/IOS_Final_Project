//
//  Helper.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 17.09.22.
//

import Foundation

class Helper {
    static func returnUserDefaultsKey(forText: String) -> String {
        switch forText {
        case "GEL":
            return Constants.userDefaultsKey.GEL.rawValue
        case "USD":
            return Constants.userDefaultsKey.USD.rawValue
        case "EUR":
            return Constants.userDefaultsKey.EUR.rawValue
        default:
            return ""
        }
    }
    
   static func returnFirebaseKey(forText: String) -> String {
        switch forText {
        case "GEL":
            return UserInformation.firebaseDataKeys.GEL.rawValue
        case "USD":
            return UserInformation.firebaseDataKeys.GEL.rawValue
        case "EUR":
            return UserInformation.firebaseDataKeys.GEL.rawValue
        default:
            return ""
        }
    }
}
