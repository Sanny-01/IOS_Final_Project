//
//  HomeRouter.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 19.09.22.


import UIKit

@objc protocol HomeRoutingLogic {
    func moveToProfile(view: UIView, parentViewController: UIViewController)
   func moveToTransfers(view: UIView, parentViewController: UIViewController)
}

protocol HomeDataPassing {
    var dataStore: HomeDataStore? { get }
}

final class HomeRouter: NSObject, HomeDataPassing {

    
    // MARK: - Clean Components
    
    weak var viewController: HomeViewController?
    var dataStore: HomeDataStore?
}

// MARK: - HomeRoutingLogic

extension HomeRouter: HomeRoutingLogic {
    func moveToProfile(view: UIView, parentViewController: UIViewController) {
        let storyboard = UIStoryboard(name: Constants.StoryBoards.profile, bundle: nil)
        guard let profileViewController = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIds.profileViewController) as? ProfileViewController else { return }
        view.addSubview(profileViewController.view)
        parentViewController.addChild(profileViewController)
        profileViewController.didMove(toParent: parentViewController)
    }
    
    func moveToTransfers(view: UIView, parentViewController: UIViewController) {
        let storyboard = UIStoryboard(name: Constants.StoryBoards.transfers, bundle: nil)
        guard let transfersViewController = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIds.transfersViewController) as? TransfersViewController else { return }
        view.addSubview(transfersViewController.view)
        parentViewController.addChild(transfersViewController)
        transfersViewController.didMove(toParent: parentViewController)
    }
}
