//
//  HomeInteractor.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 19.09.22.


import UIKit

protocol HomeBusinessLogic {
    func getUserBalace(request: Home.GetUserBalance.Request)
    func getExchangeRates(request: Home.GetExchangeRates.Request)
    func processTabBarItemTap(request: Home.TabBarItemTapped.Request)
}

protocol HomeDataStore {
}

final class HomeInteractor: HomeDataStore {
    // MARK: - Clean Components
    
    var presenter: HomePresentationLogic?
    var worker: HomeWorker?
}

// MARK: - HomeBusinessLogic

extension HomeInteractor: HomeBusinessLogic {
    func processTabBarItemTap(request: Home.TabBarItemTapped.Request) {
        presenter?.presentTintColorToTabBarComponent(response: Home.TabBarItemTapped.Response(tag: request.tag))
    }
    
    func getExchangeRates(request: Home.GetExchangeRates.Request) {
        Task {
            do {
                guard let gelToUsd = try await worker?.fetchExchangeRate(to: "GEL", from: "USD", amount: 1.00) else { return }
                guard let gelToEur = try await worker?.fetchExchangeRate(to: "GEL", from: "EUR", amount: 1.00) else { return }
                guard let gelToGbp = try await worker?.fetchExchangeRate(to: "GEL", from: "GBP", amount: 1.00) else { return }
                
                let exchangeRates = ExchangeRates(
                    gelToUsd: gelToUsd.result,
                    gelToEur: gelToEur.result,
                    gelToGbp: gelToGbp.result
                )
                
                presenter?.presentExchangeRates(response: Home.GetExchangeRates.Response(exchangeRate: exchangeRates))
            } catch {
                print("Could not load user data")
            }
        }
    }
    
    func getUserBalace(request: Home.GetUserBalance.Request) {
        Task {
            do {
                let userBalance =  try await worker?.fetchUserBalance()
                guard let userBalance = userBalance else { return }
                
                presenter?.presentUserBalance(response: Home.GetUserBalance.Response(balance: userBalance))
            } catch {
                print("Could not load user data")
            }
        }
    }
}
