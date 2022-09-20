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
}

final class HomePresenter {
    // MARK: - Clean Components
    
    weak var viewController: HomeDisplayLogic?
}

extension HomePresenter: HomePresentationLogic {
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
