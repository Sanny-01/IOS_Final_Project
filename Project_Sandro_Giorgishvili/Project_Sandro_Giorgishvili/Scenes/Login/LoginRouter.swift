//
//  LoginRouter.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 16.09.22.


import UIKit

@objc protocol LoginRoutingLogic {
    func navigateToRegisterNewUsername()
    func navigateToHomeMakingItRootViewController()
}

protocol LoginDataPassing {
    var dataStore: LoginDataStore? { get }
}

final class LoginRouter: NSObject, LoginRoutingLogic, LoginDataPassing {
    // MARK: - Clean Components
    
    weak var viewController: LoginViewController?
    var dataStore: LoginDataStore?
    
    // MARK: - LoginRoutingLogic
    
    func navigateToRegisterNewUsername() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        guard let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else { return }
        
        viewController?.navigationController?.pushViewController(signUpViewController, animated: true)
    }
    
    func navigateToHomeMakingItRootViewController() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
            guard let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else { return }
            
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            guard let window = windowScene?.windows.first else { return }
            let navigationController = UINavigationController(rootViewController: homeViewController)
            
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
}
