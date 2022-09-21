//
//  Helper.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 17.09.22.
//

import Foundation
import UIKit

final class Helper {
   static func returnFirebaseKey(forText: String) -> String {
        switch forText {
        case "GEL":
            return UserInformation.firestoreDataKeys.GEL.rawValue
        case "USD":
            return UserInformation.firestoreDataKeys.USD.rawValue
        case "EUR":
            return UserInformation.firestoreDataKeys.EUR.rawValue
        default:
            return ""
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
