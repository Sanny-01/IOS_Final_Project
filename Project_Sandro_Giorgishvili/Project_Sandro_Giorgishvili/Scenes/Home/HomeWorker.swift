//
//  HomeWorker.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 19.09.22.

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol HomeWorkerLogic {
    func fetchUserBalance() async throws -> UserBalance?
    func fetchExchangeRate(to: String, from: String, amount: Double) async throws -> CurrencyAmount
}

final class HomeWorker: HomeWorkerLogic {
    //MARK: - API Call Components
    
    let baseUrl = "https://api.apilayer.com/exchangerates_data/convert?"
    let apiKey = "3kJamQMdmqGI76HLOM6zGxWvOSgwWXnx"
//    let apiKey = "1"
    
    private var api: APIManager
    
    init(apiManager: APIManager) {
        self.api = apiManager
    }
    
    // MARK: - HomeWorkerLogic
    
    func fetchExchangeRate(to: String, from: String, amount: Double) async throws -> CurrencyAmount {
        try await api.fetchExchangeRate(to: to, from: from, amount: amount, decodingType: CurrencyAmount.self)
    }
    
    func fetchUserBalance() async throws -> UserBalance? {
        guard  let userId = Auth.auth().currentUser?.uid else { return  nil}
        
        let snapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
        guard let snapshotData = snapshot.data()  else { return nil }
        
        return UserBalance.init(with: snapshotData)
    }
}
