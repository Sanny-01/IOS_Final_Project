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
        let storyboard = UIStoryboard(name: Constants.StoryBoards.signUp, bundle: nil)
        guard let signUpViewController = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIds.signUpViewController) as? SignUpViewController else { return }
        
        viewController?.navigationController?.pushViewController(signUpViewController, animated: true)
    }
    
    func navigateToHomeMakingItRootViewController() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: Constants.StoryBoards.home, bundle: nil)
            guard let homeViewController = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIds.homeViewController) as? HomeViewController else { return }
            
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            guard let window = windowScene?.windows.first else { return }
            let navigationController = UINavigationController(rootViewController: homeViewController)
            
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
}
