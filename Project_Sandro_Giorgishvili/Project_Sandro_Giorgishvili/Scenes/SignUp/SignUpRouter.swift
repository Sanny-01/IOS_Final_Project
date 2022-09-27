//
//  SignUpRouter.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 17.09.22.
import UIKit

@objc protocol SignUpRoutingLogic {
    func popToHome()
}

protocol SignUpDataPassing {
    var dataStore: SignUpDataStore? { get }
}

final class SignUpRouter: NSObject, SignUpRoutingLogic {
    
    weak var viewController: SignUpViewController?
    var dataStore: SignUpDataStore?
    
    // MARK: - SignUpRoutingLogic
    
    func popToHome() {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.navigationController?.popViewController(animated: true)
        }
    }
}
