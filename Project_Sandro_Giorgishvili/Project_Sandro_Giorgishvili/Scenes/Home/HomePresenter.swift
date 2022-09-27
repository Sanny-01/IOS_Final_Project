//
//  HomePresenter.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 19.09.22.

import UIKit

protocol HomePresentationLogic {
    func presentUserBalance(response: Home.GetUserBalance.Response)
    func presentExchangeRates(response: Home.GetExchangeRates.Response)
    func presentTintColorToTabBarComponent(response: Home.TabBarItemTapped.Response)
    func presentAlert(response: Home.ShowAlert.Response)
    func presentHideSpinner(response: Home.HideSpinner.Response)
}

final class HomePresenter {
    // MARK: - Clean Components
    
    weak var viewController: HomeDisplayLogic?
}

extension HomePresenter: HomePresentationLogic {
    func presentHideSpinner(response: Home.HideSpinner.Response) {
        viewController?.displayHideSpinner(viewModel: Home.HideSpinner.ViewModel())
    }
    
    func presentAlert(response: Home.ShowAlert.Response) {
        viewController?.displayAlert(viewModel: Home.ShowAlert.ViewModel(title: response.title, message: response.message))
    }
    
    func presentTintColorToTabBarComponent(response: Home.TabBarItemTapped.Response) {
        viewController?.displayTabBarItemPage(viewModel: Home.TabBarItemTapped.ViewModel(tag: response.tag))
    }
    
    func presentExchangeRates(response: Home.GetExchangeRates.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayExchangeRates(viewModel: Home.GetExchangeRates.ViewModel(exchangeRate: response.exchangeRate))
        }
    }
    
    func presentUserBalance(response: Home.GetUserBalance.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayUserBalance(viewModel: Home.GetUserBalance.ViewModel(balance: response.balance))
        }
    }
}
